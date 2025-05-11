import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mama_pill/core/helpers/values.dart';
import 'package:mama_pill/core/presentation/widgets/custom_card_tile.dart';
import 'package:mama_pill/core/presentation/widgets/medicine_icon_card.dart';
import 'package:mama_pill/core/resources/colors.dart';
import 'package:mama_pill/core/resources/values.dart';
import 'package:mama_pill/core/utils/bottom_sheet_utils.dart';
import 'package:mama_pill/core/utils/extensions.dart';
import 'package:mama_pill/features/medicine/domain/entities/medicine_schedule.dart';
import 'package:mama_pill/features/medicine/presentation/widgets/edit_medicine_form.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mama_pill/features/medicine/presentation/controller/medicine_schedule/bloc/medicine_schedule_bloc.dart';

class MedicineScheduleTile extends StatelessWidget {
  const MedicineScheduleTile({
    super.key,
    required this.medicineSchedule,
  });
  final MedicineSchedule medicineSchedule;

  @override
  Widget build(BuildContext context) {
    final String intake = Values.getIntakePerWeek(
      medicineSchedule.dose,
      medicineSchedule.schedule.times.length,
      medicineSchedule.schedule.days.length,
    ).toString();
    return CustomCardTile(
      onTap: () => BottomSheetUtils.showButtomSheet(
        context,
        EditDispenserForm(
          medicine: medicineSchedule,
          index: medicineSchedule.index,
        ),
      ),
      icon: MedicineIconCard(type: medicineSchedule.type),
      title: medicineSchedule.medicine,
      subtitle: '$intake ${medicineSchedule.type.shortName} / week',
      footer: Center(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 2, vertical: 0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
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
                padding: EdgeInsets.all(4),
                constraints: BoxConstraints(),
              ),
              Container(
                width: 1,
                height: 18,
                color: Colors.grey.shade300,
              ),
              IconButton(
                icon: Icon(Icons.delete, color: Colors.red, size: 18),
                tooltip: 'Delete',
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
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Expanded(
                                  child: OutlinedButton(
                                    onPressed: () => Navigator.of(ctx).pop(),
                                    style: OutlinedButton.styleFrom(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    child: Text('Cancel',
                                        style:
                                            TextStyle(color: Colors.black87)),
                                  ),
                                ),
                                SizedBox(width: 16),
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: () {
                                      Navigator.of(ctx).pop();
                                      final medicineScheduleBloc =
                                          BlocProvider.of<MedicineScheduleBloc>(
                                              context,
                                              listen: false);
                                      medicineScheduleBloc.add(
                                        MedicineScheduleDeleted(
                                            medicineId: medicineSchedule.id),
                                      );
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.red,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    child: Text('Delete',
                                        style: TextStyle(color: Colors.white)),
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
                padding: EdgeInsets.all(4),
                constraints: BoxConstraints(),
              ),
            ],
          ),
        ),
      ),
      color: medicineSchedule.type.color.withOpacity(0.1),
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
