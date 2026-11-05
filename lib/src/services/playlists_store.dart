import 'package:flutter/material.dart';

class PlaylistsStore {
  PlaylistsStore._();
  static final instance = PlaylistsStore._();

  final ValueNotifier<List<String>> playlists = ValueNotifier<List<String>>(['Local']);

  void add(String name) {
    if (name.trim().isEmpty) return;
    playlists.value = [...playlists.value, name.trim()];
  }
}
