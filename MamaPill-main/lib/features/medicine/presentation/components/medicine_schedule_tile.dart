import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mama_pill/core/presentation/widgets/medicine_icon_card.dart';
import 'package:mama_pill/core/resources/colors.dart';
import 'package:mama_pill/core/resources/values.dart';
import 'package:mama_pill/core/utils/bottom_sheet_utils.dart';
import 'package:mama_pill/core/utils/enums.dart';
import 'package:mama_pill/core/utils/extensions.dart';
import 'package:mama_pill/features/medicine/domain/entities/medicine_schedule.dart';
import 'package:mama_pill/features/medicine/presentation/widgets/edit_medicine_form.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mama_pill/features/authentication/presentation/controller/auth/bloc/auth_bloc.dart';
import 'package:mama_pill/features/medicine/presentation/controller/medicine_schedule/bloc/medicine_schedule_bloc.dart';

class MedicineScheduleTile extends StatelessWidget {

  bool _shouldShowCheckmark(MedicineSchedule medicine) {
    final now = DateTime.now();
    
    // Check if today is a scheduled day
    if (!medicine.schedule.days.contains(now.weekday)) {
      return false;
    }
    
    // Check if any scheduled time has passed
    for (final scheduledTime in medicine.schedule.times) {
      final parts = scheduledTime.split(':');
      final hour = int.parse(parts[0]);
      final minute = int.parse(parts[1].split(' ')[0]); // Remove AM/PM
      final isPM = scheduledTime.toLowerCase().contains('pm');
      
      final scheduleHour = isPM && hour != 12 ? hour + 12 : hour;
      final scheduleDateTime = DateTime(now.year, now.month, now.day, scheduleHour, minute);
      
      // If the scheduled time has passed, show checkmark
      if (now.isAfter(scheduleDateTime)) {
        return true;
      }
    }
    return false;
  }

  const MedicineScheduleTile({
    super.key,
    required this.medicineSchedule,
  });
  final MedicineSchedule medicineSchedule;

  @override
  Widget build(BuildContext context) {
    final String intake =
        '${medicineSchedule.dose * medicineSchedule.schedule.times.length * medicineSchedule.schedule.days.length}';

    // Get current user role
    final authState = context.read<AuthBloc>().state;
    final isDoctor = authState.user.role == UserRole.doctor;
    
    return _buildContent(context, intake, isDoctor);
  }
  
  Widget _buildContent(BuildContext context, String intake, bool isDoctor) {
    final titleStyle = Theme.of(context).textTheme.titleMedium?.copyWith(
      fontWeight: FontWeight.w700,
      fontSize: 16.sp,
    );
    
    final subtitleStyle = Theme.of(context).textTheme.bodyMedium?.copyWith(
      fontSize: 14.sp,
      fontWeight: FontWeight.w600,
      color: Colors.black87,
      height: 1.3,
    );
    
    final timeStyle = Theme.of(context).textTheme.bodyMedium?.copyWith(
      color: Colors.black54,
      fontSize: 14.sp,
      fontWeight: FontWeight.w600,
      height: 1.2,
      letterSpacing: 0.2,
    );
    
    // Use a single container with direct Column child
    return Container(
      width: 130.w, // Increased width to prevent overflow
      height: 200.h, // Adjusted height to fit within CardSectionBody
      margin: EdgeInsets.only(right: 10.w),
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 14.h),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.r),
        color: medicineSchedule.type.color.withOpacity(0.1),
      ),
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon at the top with Taken indicator
            Row(
              mainAxisSize: MainAxisSize.max, // Use max to fill the width
              mainAxisAlignment: MainAxisAlignment.spaceBetween, // Space between icon and taken sign
              children: [
                MedicineIconCard(type: medicineSchedule.type),
                if (_shouldShowCheckmark(medicineSchedule))
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 3.h),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.15), // Slightly more visible background
                      borderRadius: BorderRadius.circular(10.r), // Larger radius
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.check_circle,
                          color: Colors.green,
                          size: 14.sp, // Slightly bigger icon
                        ),
                        SizedBox(width: 3.w), // More spacing
                        Text(
                          'Taken',
                          style: TextStyle(
                            color: Colors.green,
                            fontSize: 12.sp, // Bigger text
                            fontWeight: FontWeight.w600, // Bolder text
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            SizedBox(height: 8.h),
            
            // Title section
            Text(
              medicineSchedule.medicine,
              style: titleStyle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            
            SizedBox(height: 4.h),
            
            // Subtitle section
            Text(
              '$intake ${medicineSchedule.type.shortName} over ${medicineSchedule.schedule.weeksCount} ${medicineSchedule.schedule.weeksCount == 1 ? 'week' : 'weeks'}',
              style: subtitleStyle,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            
            SizedBox(height: 4.h),
            
            // Time schedule
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(
                  Icons.schedule,
                  size: 16.sp,
                  color: Colors.black54,
                ),
                SizedBox(width: 4.w),
                Expanded(
                  child: Text(
                    medicineSchedule.schedule.times.map((time) {
                      // Split time and AM/PM
                      final parts = time.split(' ');
                      if (parts.length == 2) {
                        return '${parts[0]} ${parts[1].toUpperCase()}';
                      }
                      return time;
                    }).join(' '), // Space between times
                    style: timeStyle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            
            Spacer(), // Push footer to bottom
            
            SizedBox(height: 8.h), // Add more space before buttons
            
            // Only show edit/delete buttons for doctors
            if (isDoctor)
              Center(
                child: Container(
                  width: 90.w, // Set fixed width for button container
                  padding: EdgeInsets.symmetric(horizontal: 2.w),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16.r),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 2,
                        offset: Offset(0, 1),
                      ),
                    ],
                    border: Border.all(
                        color: medicineSchedule.type.color.withOpacity(0.15)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Compact edit button
                      IconButton(
                        icon: Icon(Icons.edit,
                            color: medicineSchedule.type.color, size: 18),
                        tooltip: 'Edit',
                        onPressed: () => BottomSheetUtils.showButtomSheet(
                          context,
                          EditDispenserForm(
                            medicine: medicineSchedule,
                            index: medicineSchedule.index,
                          ),
                        ),
                        padding: EdgeInsets.zero,
                        constraints: BoxConstraints(maxWidth: 36.w, minWidth: 36.w),
                        iconSize: 18.sp,
                      ),
                      Container(
                        width: 1,
                        height: 18,
                        color: Colors.grey.shade300,
                      ),
                      // Compact delete button
                      IconButton(
                        icon: Icon(Icons.delete, color: Colors.red, size: 18),
                        tooltip: 'Delete',
                        padding: EdgeInsets.zero,
                        constraints: BoxConstraints(maxWidth: 36.w, minWidth: 36.w),
                        iconSize: 18.sp,
                        onPressed: () {
                          showDialog(
                            context: context,
                            barrierDismissible: true,
                            builder: (ctx) => Dialog(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(24)),
                              elevation: 0,
                              backgroundColor: Colors.white,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 24, vertical: 24),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.delete_forever,
                                        color: Colors.red, size: 48),
                                    SizedBox(height: 16),
                                    Text(
                                      'Delete Medicine?',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 20,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    SizedBox(height: 12),
                                    Text(
                                      'Are you sure you want to delete this medicine?',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: Colors.black54,
                                        fontSize: 16,
                                      ),
                                    ),
                                    SizedBox(height: 24),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: [
                                        Expanded(
                                          child: OutlinedButton(
                                            onPressed: () =>
                                                Navigator.of(ctx).pop(),
                                            style: OutlinedButton.styleFrom(
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                            ),
                                            child: Text('Cancel',
                                                style: TextStyle(
                                                    color: Colors.black87)),
                                          ),
                                        ),
                                        SizedBox(width: 16),
                                        Expanded(
                                          child: ElevatedButton(
                                            onPressed: () {
                                              Navigator.of(ctx).pop();
                                              final medicineScheduleBloc =
                                                  BlocProvider.of<
                                                          MedicineScheduleBloc>(
                                                      context);
                                              medicineScheduleBloc.add(
                                                MedicineScheduleDeleted(
                                                  medicineId: medicineSchedule.id,
                                                ),
                                              );
                                            },
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.red,
                                              foregroundColor: Colors.white,
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                            ),
                                            child: Text('Delete'),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            // Empty placeholder if not doctor
            if (!isDoctor)
              Container(),
          ],
        ),
      );
  }
}

class CardTileFooter extends StatelessWidget {
  const CardTileFooter({
    super.key,
    required this.color,
  });
  final Color color;

  @override
  Widget build(BuildContext context) {
    TextTheme textTheme = Theme.of(context).textTheme;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Center(
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 4.h, horizontal: 14.w).w,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.rectangle,
              borderRadius: BorderRadius.circular(100).w,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Padding(
                  padding: AppPadding.smallH,
                  child: Text(
                    'Edit',
                    style: textTheme.titleSmall!.copyWith(
                      fontSize: AppFontSize.f12.sp,
                      color: AppColors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
