import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_fonts.dart';

class AppTextStyle {
  // Tiêu đề chính của màn hình
  static const TextStyle heading = TextStyle(
    fontFamily: AppFonts.primaryFont,
    fontSize: 22,
    fontWeight: FontWeight.bold,
    color: AppColors.text,
  );

  // Văn bản nội dung task
  static const TextStyle body = TextStyle(
    fontFamily: AppFonts.primaryFont,
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: AppColors.textLight,
  );

  // Task đã hoàn thành (có gạch ngang)
  static const TextStyle completed = TextStyle(
    fontFamily: AppFonts.primaryFont,
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: AppColors.textLight,
    decoration: TextDecoration.lineThrough,
    decorationThickness: 2,
  );

  // Text nhỏ: timestamp, phụ chú, label
  static const TextStyle small = TextStyle(
    fontFamily: AppFonts.primaryFont,
    fontSize: 13,
    color: AppColors.textLight,
  );

  // Text nút bấm
  static const TextStyle button = TextStyle(
    fontFamily: AppFonts.primaryFont,
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: Colors.white,
  );

  // Lỗi (như validate form, hoặc empty task)
  static const TextStyle error = TextStyle(
    fontFamily: AppFonts.primaryFont,
    fontSize: 14,
    color: Colors.redAccent,
  );
}
