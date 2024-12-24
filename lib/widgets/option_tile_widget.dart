import 'package:flutter/material.dart';

class OptionTileWidget extends StatefulWidget {
  final String option, optionTitle, answer, optionSelected;

  const OptionTileWidget(
      {super.key,
      required this.option,
      required this.optionTitle,
      required this.answer,
      required this.optionSelected});

  @override
  State<OptionTileWidget> createState() => _OptionTileWidgetState();
}

class _OptionTileWidgetState extends State<OptionTileWidget> {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          decoration: BoxDecoration(
              border: Border.all(
                  color: widget.optionTitle == widget.optionSelected
                      ? widget.optionSelected == widget.answer
                          ? Colors.green.withOpacity(0.7)
                          : Colors.red.withOpacity(0.7)
                      : Colors.grey)),
          child: Text(
            widget.option,
            style: TextStyle(
                color: widget.optionTitle == widget.optionSelected
                    ? widget.optionSelected == widget.answer
                        ? Colors.green.withOpacity(0.7)
                        : Colors.red.withOpacity(0.7)
                    : Colors.grey),
          ),
        ),
        Text(
          widget.optionTitle,
          style: const TextStyle(fontSize: 17, color: Colors.black54),
        )
      ],
    );
  }
}
