import 'package:flutter/material.dart';

Widget buildSettingsCard({required Widget child}) => Container(
  padding: const EdgeInsets.all(16),
  decoration: BoxDecoration(
    color: Colors.white, borderRadius: BorderRadius.circular(14),
    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 3))],
  ),
  child: child,
);

Widget buildSectionTitle(String t, IconData icon) {
  const kPrimary = Color(0xFF1A237E);
  return Row(children: [
    Icon(icon, color: kPrimary, size: 18),
    const SizedBox(width: 8),
    Text(t, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF212121))),
  ]);
}

Widget buildDivider() => const Divider(height: 1, indent: 52, color: Color(0xFFF0F0F0));

Widget buildToggleRow(String label, String subtitle, IconData icon, Color col, bool value, ValueChanged<bool> onChanged) {
  const kPrimary = Color(0xFF1A237E);
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 10),
    child: Row(children: [
      Container(
        width: 38, height: 38,
        decoration: BoxDecoration(color: col.withOpacity(0.10), borderRadius: BorderRadius.circular(10)),
        child: Icon(icon, color: col, size: 20),
      ),
      const SizedBox(width: 12),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Color(0xFF212121))),
        if (subtitle.isNotEmpty)
          Text(subtitle, style: const TextStyle(fontSize: 11, color: Color(0xFF9E9E9E))),
      ])),
      Switch(
        value: value, onChanged: onChanged,
        activeColor: Colors.white, activeTrackColor: kPrimary,
        inactiveThumbColor: Colors.white, inactiveTrackColor: const Color(0xFFBDBDBD),
      ),
    ]),
  );
}

Widget buildMenuRow(String label, String subtitle, IconData icon, Color col, VoidCallback onTap) {
  return InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(10),
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(children: [
        Container(
          width: 38, height: 38,
          decoration: BoxDecoration(color: col.withOpacity(0.10), borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, color: col, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Color(0xFF212121))),
          if (subtitle.isNotEmpty)
            Text(subtitle, style: const TextStyle(fontSize: 11, color: Color(0xFF9E9E9E))),
        ])),
        Icon(Icons.chevron_right, color: Colors.grey[400], size: 22),
      ]),
    ),
  );
}

Widget buildActionBtn(String label, Color color, IconData icon, VoidCallback onTap) {
  return GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 11),
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(9)),
      child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(icon, color: Colors.white, size: 16),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13)),
      ]),
    ),
  );
}
