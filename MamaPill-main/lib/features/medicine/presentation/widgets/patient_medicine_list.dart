import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mama_pill/core/resources/colors.dart';
import 'package:mama_pill/core/utils/enums.dart';
import 'package:mama_pill/features/authentication/domain/entities/user_profile.dart';
import 'package:mama_pill/features/authentication/presentation/controller/auth/bloc/auth_bloc.dart';
import 'package:mama_pill/features/authentication/presentation/controller/patients/bloc/patients_bloc.dart';
import 'package:mama_pill/features/medicine/presentation/controller/all_medicines_schedule/bloc/all_medicines_schedule_bloc.dart';

class PatientMedicineList extends StatefulWidget {
  const PatientMedicineList({Key? key}) : super(key: key);

  @override
  State<PatientMedicineList> createState() => _PatientMedicineListState();
}

class _PatientMedicineListState extends State<PatientMedicineList>
    with AutomaticKeepAliveClientMixin {
  UserProfile? _selectedPatient;
  bool _mounted = true;

  @override
  void initState() {
    super.initState();
    // Fetch patients list when widget is initialized
    if (_mounted) {
      // Request patients and medicines in parallel
      context.read<PatientsBloc>().add(const PatientsRequested());
      context.read<AllMedicinesScheduleBloc>().add(
        const AllDispensersFetched(),
      );
    }
  }

  @override
  void dispose() {
    _mounted = false;
    super.dispose();
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        // Hide for patients
        if (authState.user.role == UserRole.patient) {
          return const SizedBox.shrink();
        }

        // Initialize patients fetch
        if (_mounted) {
          context.read<PatientsBloc>().add(const PatientsRequested());
        }

        return BlocBuilder<PatientsBloc, PatientsState>(
          builder: (context, patientsState) {
            if (patientsState.status == RequestStatus.loading &&
                patientsState.patients.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }

            if (patientsState.patients.isEmpty) {
              return Center(
                child: Text(
                  'No patients found',
                  style: TextStyle(
                    fontSize: 16.sp,
                    color: AppColors.textSecondary,
                  ),
                ),
              );
            }

            return Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<UserProfile>(
                      value: _selectedPatient,
                      isExpanded: true,
                      icon: Padding(
                        padding: EdgeInsets.only(right: 8.w),
                        child: Icon(
                          Icons.keyboard_arrow_down_rounded,
                          color: AppColors.accent,
                          size: 20.sp,
                        ),
                      ),
                      hint: Text(
                        'Select Patient',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 14.sp,
                        ),
                      ),
                      decoration: InputDecoration(
                        labelText: null,
                        labelStyle: TextStyle(
                          color: AppColors.accent,
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w500,
                        ),
                        filled: true,
                        fillColor: Colors.grey[50],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.r),
                          borderSide: BorderSide(
                            color: AppColors.accent.withOpacity(0.2),
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.r),
                          borderSide: BorderSide(
                            color: AppColors.accent.withOpacity(0.2),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.r),
                          borderSide: BorderSide(color: AppColors.accent),
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16.w,
                          vertical: 12.h,
                        ),
                        constraints: BoxConstraints(minHeight: 48.h),
                      ),
                      items: [
                        // Add 'Select Patient' as first item with null value
                        DropdownMenuItem<UserProfile>(
                          value: null,
                          child: Text(
                            'Select Patient',
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        // Then add all patients
                        ...patientsState.patients.map((patient) {
                          return DropdownMenuItem(
                            value: patient,
                            child: Text(
                              '${patient.username} (ID: ${patient.patientId})',
                              style: TextStyle(
                                fontSize: 14.sp,
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          );
                        }).toList(),
                      ],
                      onChanged: (patient) {
                        if (_mounted) {
                          setState(() => _selectedPatient = patient);

                          // Clear medicines if Select Patient is chosen
                          if (patient == null) {
                            context.read<AllMedicinesScheduleBloc>().add(
                              const AllDispensersFetched(dispensers: []),
                            );
                          }
                        }
                      },
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Container(
                    height: 48.h,
                    child: ElevatedButton(
                      onPressed: () {
                        if (_selectedPatient == null) {
                          // Clear medicines when no patient is selected
                          context.read<AllMedicinesScheduleBloc>().add(
                            const AllDispensersFetched(dispensers: []),
                          );
                          return;
                        }
                        // Start listening to medicines for selected patient
                        context
                            .read<AllMedicinesScheduleBloc>()
                            .startListeningToMedicines(
                              context.read<AuthBloc>().state.user.id!,
                              _selectedPatient!.patientId!,
                            );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.accent,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: EdgeInsets.symmetric(horizontal: 12.w),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                      ),
                      child: Icon(Icons.search_rounded, size: 20.sp),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
