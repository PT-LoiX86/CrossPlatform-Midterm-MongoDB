import 'package:flutter/material.dart';

import '../models/lecturer.dart';
import 'lecturer_avatar.dart';

class LecturerProfileDialog extends StatelessWidget {
  const LecturerProfileDialog({super.key, required this.lecturer});

  final Lecturer lecturer;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(22, 24, 22, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close_rounded),
                ),
              ),
              LecturerAvatar(imagePath: lecturer.image, radius: 58),
              const SizedBox(height: 16),
              Text(
                lecturer.fullname,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 21,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF18344F),
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'LECTURER PROFILE',
                style: TextStyle(
                  fontSize: 11,
                  letterSpacing: 1.4,
                  color: Color(0xFF7C91A4),
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 24),
              _ProfileRow(
                label: 'Lecturer ID',
                value: lecturer.idgv,
                icon: Icons.badge_outlined,
              ),
              const SizedBox(height: 12),
              _ProfileRow(
                label: 'Fullname',
                value: lecturer.fullname,
                icon: Icons.person_outline_rounded,
              ),
              const SizedBox(height: 12),
              _ProfileRow(
                label: 'Total classes',
                value: '${lecturer.sumClass}',
                icon: Icons.school_outlined,
              ),
              const SizedBox(height: 22),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Close'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProfileRow extends StatelessWidget {
  const _ProfileRow({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: const Color(0xFFF4F8FC),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF1769AA), size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF7C91A4),
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  value,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF18344F),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
