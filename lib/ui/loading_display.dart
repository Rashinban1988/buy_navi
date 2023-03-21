import 'package:flutter/material.dart';

class LoadingDisplay extends StatelessWidget {
  const LoadingDisplay({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
        alignment: Alignment.center,
        child: const CircularProgressIndicator(
          color: Color.fromARGB(255, 0, 89, 255),
        ));
  }
}
