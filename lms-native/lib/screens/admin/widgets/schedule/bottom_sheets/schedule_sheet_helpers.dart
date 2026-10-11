import 'package:flutter/material.dart';

Widget buildSheetHandle() => Center(
      child: Container(
        margin: const EdgeInsets.only(top: 12, bottom: 8),
        width: 40,
        height: 4,
        decoration: BoxDecoration(
            color: const Color(0xFFE0D8F0),
            borderRadius: BorderRadius.circular(2)),
      ),
    );

Widget buildSheetHeader(String title, IconData icon) {
  const kPrimary = Color(0xFF1A237E);
  return Padding(
    padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
    child: Row(children: [
      Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
              color: kPrimary.withOpacity(0.1), shape: BoxShape.circle),
          child: Icon(icon, color: kPrimary, size: 20)),
      const SizedBox(width: 12),
      Text(title,
          style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Color(0xFF212121))),
    ]),
  );
}

Widget buildSheetField(String label, String hint) => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(fontSize: 12, color: Color(0xFF616161))),
        const SizedBox(height: 4),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
          decoration: BoxDecoration(
              border: Border.all(color: const Color(0xFFE0D8F0)),
              borderRadius: BorderRadius.circular(8)),
          child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                    child: Text(hint,
                        style: const TextStyle(
                            fontSize: 13, color: Color(0xFF424242)))),
                const Icon(Icons.keyboard_arrow_down,
                    color: Color(0xFF1A237E), size: 18),
              ]),
        ),
      ],
    );

Widget buildSheetSubmitBtn(BuildContext ctx, String label) {
  const kPrimary = Color(0xFF1A237E);
  return GestureDetector(
    onTap: () => Navigator.pop(ctx),
    child: Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 13),
      decoration: BoxDecoration(
          gradient: const LinearGradient(
              colors: [Color(0xFF0D1B6E), kPrimary]),
          borderRadius: BorderRadius.circular(10)),
      child: Center(
          child: Text(label,
              style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 14))),
    ),
  );
}
