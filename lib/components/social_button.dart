import 'package:flutter/material.dart';
import 'package:flutter_doctor_app/utils/config.dart';

class SocialButton extends StatelessWidget {
  const SocialButton({super.key,required this.social,});

  final String social;

  @override
  Widget build(BuildContext context) {
    Config().init(context);
    return OutlinedButton(
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 15,),
        side: const BorderSide(width: 1, color: Colors.black38),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      onPressed: () {},
      child: SizedBox(
        width: Config.widthSize * 0.4,
        height: Config.heightSize * 0.03,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            Image.asset(
              'assets/$social.png',
              width: 49,
              height: 40,
              ),
              Text(
                social.toUpperCase(),
                style: const TextStyle(
                  color: Colors.black,
                ),
              )
              
              
          ],
        ),
      )
    );
  }
}