import 'package:flutter/material.dart';
import 'package:medicine/core/constants/app_colors.dart';

class EditMedicineForm extends StatefulWidget {
  // ... (existing code)
}

class _EditMedicineFormState extends State<EditMedicineForm> {
  // ... (existing code)

  void _showTimePicker(
    BuildContext context,
    MedicineFormCubit medcineFormCubit,
  ) async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: AppColors.white,
              surface: AppColors.backgroundPrimary,
              onSurface: AppColors.primary,
            ),
            textTheme: Theme.of(context).textTheme.copyWith(
              bodyLarge: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
              bodyMedium: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedTime != null) {
      final formattedTime = pickedTime.format(context);
      medcineFormCubit.addTime(formattedTime);
    }
  }

  // ... (rest of the existing code)
}
