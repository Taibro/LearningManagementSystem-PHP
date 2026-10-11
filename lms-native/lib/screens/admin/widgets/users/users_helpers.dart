import 'package:flutter/material.dart';

Widget buildSearchBar(String hint, ValueChanged<String> onChanged) {
  const kPrimary = Color(0xFF1A237E);
  return Container(
    color: Colors.transparent,
    padding: const EdgeInsets.fromLTRB(20, 10, 20, 6),
    child: TextField(
      decoration: InputDecoration(
        hintText: hint, hintStyle: const TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
        prefixIcon: const Icon(Icons.search, size: 20, color: Color(0xFF64748B)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        filled: true,
        fillColor: Colors.white.withOpacity(0.8),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.transparent)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.transparent)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: kPrimary.withOpacity(0.3), width: 1.5)),
      ),
      style: const TextStyle(fontSize: 13),
      onChanged: onChanged,
    ),
  );
}

Widget buildFilterRow(List<String> filters, String selected, ValueChanged<String> onTap) {
  const kPrimary = Color(0xFF1A237E);
  return Container(
    color: Colors.transparent,
    padding: const EdgeInsets.only(left: 20, right: 20, bottom: 10),
    child: SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(children: filters.map((f) {
        final sel = selected == f;
        return Padding(padding: const EdgeInsets.only(right: 8), child: GestureDetector(
          onTap: () => onTap(f),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: sel ? kPrimary : Colors.white.withOpacity(0.8),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: sel ? kPrimary : Colors.transparent),
              boxShadow: sel ? [BoxShadow(color: kPrimary.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 2))] : null,
            ),
            child: Text(f, style: TextStyle(fontSize: 12, color: sel ? Colors.white : const Color(0xFF475569), fontWeight: FontWeight.bold)),
          ),
        ));
      }).toList()),
    ),
  );
}

Widget buildAvatarWidget(String letter, List<Color> colors) {
  return Container(
    width: 46, height: 46,
    decoration: BoxDecoration(shape: BoxShape.circle, gradient: LinearGradient(colors: colors)),
    child: Center(child: Text(letter, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18))),
  );
}

Widget buildChipWidget(String label, Color color) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
    decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
    child: Text(label, style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.w600)),
  );
}

PopupMenuItem<String> buildPopupItem(String value, IconData icon, String label, Color? color) {
  return PopupMenuItem(value: value, child: Row(children: [
    Icon(icon, size: 16, color: color),
    const SizedBox(width: 8),
    Text(label, style: TextStyle(color: color)),
  ]));
}
