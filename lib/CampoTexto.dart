import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CampoTexto extends StatelessWidget {
  const CampoTexto(this.controladorTexto, {Key? key}) : super(key: key);
  final TextEditingController controladorTexto;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: TextField(
        controller: controladorTexto,
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp(r"[\d.]")),
          LengthLimitingTextInputFormatter(8),
        ],
        decoration:const InputDecoration(border: OutlineInputBorder(), hintText: 'CEP'),
      ),
    );
  }
}