import 'package:flutter/material.dart';

import '../models/lecturer.dart';
import 'lecturer_avatar.dart';

class LecturerCard extends StatelessWidget {
  const LecturerCard({
    super.key,
    required this.lecturer,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  final Lecturer lecturer;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: const BorderSide(color: Color(0xFFE5EDF5)),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              LecturerAvatar(imagePath: lecturer.image, radius: 29),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      lecturer.fullname,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF18344F),
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      'ID: ${lecturer.idgv}',
                      style: const TextStyle(
                        color: Color(0xFF6B7F91),
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      '${lecturer.sumClass} classes',
                      style: const TextStyle(
                        color: Color(0xFF1769AA),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                tooltip: 'Lecturer actions',
                onSelected: (value) {
                  if (value == 'edit') onEdit();
                  if (value == 'delete') onDelete();
                },
                itemBuilder: (context) => const [
                  PopupMenuItem(
                    value: 'edit',
                    child: ListTile(
                      leading: Icon(Icons.edit_outlined),
                      title: Text('Edit'),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                  PopupMenuItem(
                    value: 'delete',
                    child: ListTile(
                      leading: Icon(Icons.delete_outline, color: Colors.red),
                      title: Text('Delete'),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ],
                child: const Padding(
                  padding: EdgeInsets.all(7),
                  child: Icon(
                    Icons.more_vert_rounded,
                    color: Color(0xFF6B7F91),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
