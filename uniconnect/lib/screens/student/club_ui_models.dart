import 'package:flutter/material.dart';

enum ClubActionResult { join, leave }

@immutable
class UiClub {
  final String id;
  final String name;
  final String description;
  final String category;
  final int members;
  final int events;
  final IconData icon;
  final Color color;
  final bool isAdmin;
  final bool isJoined;
  final List<String> announcements;

  const UiClub({
    required this.id,
    required this.name,
    this.description = '',
    this.category = '',
    this.members = 0,
    this.events = 0,
    required this.icon,
    required this.color,
    this.isAdmin = false,
    this.isJoined = false,
    this.announcements = const [],
  });

  UiClub copyWith({
    String? id,
    String? name,
    String? description,
    String? category,
    int? members,
    int? events,
    IconData? icon,
    Color? color,
    bool? isAdmin,
    bool? isJoined,
    List<String>? announcements,
  }) {
    return UiClub(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      category: category ?? this.category,
      members: members ?? this.members,
      events: events ?? this.events,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      isAdmin: isAdmin ?? this.isAdmin,
      isJoined: isJoined ?? this.isJoined,
      announcements: announcements ?? this.announcements,
    );
  }
}
