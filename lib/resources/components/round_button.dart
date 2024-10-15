import 'package:flutter/material.dart';
import 'package:superior_weather/resources/colors.dart';

class RoundButton extends StatelessWidget {
  final String message;
  final bool loading;
  final VoidCallback onPress;
  const RoundButton(
      {super.key,
      required this.message,
      this.loading = false,
      required this.onPress});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPress,
      child: Container(
        height: 50,
        width: 200,
        decoration: BoxDecoration(
            color: AppColors.buttonColor,
            borderRadius: BorderRadius.circular(10)),
        child: Center(
          child: loading
              ? const CircularProgressIndicator(
                  color: Colors.white,
                )
              : Text(message),
        ),
      ),
    );
  }
}
