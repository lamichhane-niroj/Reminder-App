import 'package:flutter/material.dart';
import 'package:todo_list/utils/app_theme.dart';

class AppStyles {
  static const heading1 =
      TextStyle(color: AppColors.textColor, fontWeight: FontWeight.bold);
  
  static const heading2 =
      TextStyle(color: AppColors.red, fontWeight: FontWeight.bold);

  static const title2 = TextStyle(
      color: AppColors.white, fontSize: 15, fontWeight: FontWeight.w400);

  static const subtitle2 = TextStyle(
      color: AppColors.gray, fontSize: 15, fontWeight: FontWeight.w400);

  static const dialogBoxTitle =
      TextStyle(color: AppColors.secondaryBlue, fontWeight: FontWeight.w500);

  static const dialogBoxConfirm = TextStyle(color: AppColors.secondaryBlue);
  static const dialogBoxCancel = TextStyle(color: AppColors.red);
}
