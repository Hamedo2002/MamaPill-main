import 'package:flutter/material.dart';
import 'package:mama_pill/core/resources/assets.dart';
import 'package:mama_pill/core/resources/colors.dart';
import 'package:mama_pill/core/utils/enums.dart';

extension MedicineTypeX on MedicineType {
  String get name {
    switch (this) {
      case MedicineType.tablet:
        return 'tablet';
      case MedicineType.capsule:
        return 'capsule';
      case MedicineType.liquid:
        return 'liquid';
    }
  }

  String get shortName {
    switch (this) {
      case MedicineType.tablet:
        return 'tab';
      case MedicineType.capsule:
        return 'cap';
      case MedicineType.liquid:
        return 'liq';
    }
  }

  String get icon {
    switch (this) {
      case MedicineType.tablet:
        return AppAssets.tablet;
      case MedicineType.capsule:
        return AppAssets.capsule;
      case MedicineType.liquid:
        return AppAssets.liquid;
    }
  }

  Color get color {
    switch (this) {
      case MedicineType.tablet:
        return AppColors.accent;
      case MedicineType.capsule:
        return AppColors.primary;
      case MedicineType.liquid:
        return AppColors.liquidColor3;
    }
  }
}
