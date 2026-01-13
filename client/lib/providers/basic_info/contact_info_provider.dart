import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:erpcrm_client/models/basic_info/contact_info.dart';

class ContactInfoState {
  final List<ContactInfo> contacts;
  final bool isLoading;
  final String? error;

  const ContactInfoState({
    this.contacts = const [],
    this.isLoading = false,
    this.error,
  });

  ContactInfoState copyWith({
    List<ContactInfo>? contacts,
    bool? isLoading,
    String? error,
  }) {
    return ContactInfoState(
      contacts: contacts ?? this.contacts,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

class ContactInfoNotifier extends StateNotifier<ContactInfoState> {
  final Box contactInfoBox;

  ContactInfoNotifier(this.contactInfoBox) : super(const ContactInfoState()) {
    _loadContacts();
  }

  Future<void> _loadContacts() async {
    state = state.copyWith(isLoading: true);
    try {
      final contactsJson = contactInfoBox.get('contact_infos', defaultValue: <Map<String, dynamic>>[]);
      final contacts = (contactsJson as List).map((json) => ContactInfo.fromJson(json as Map<String, dynamic>)).toList();
      state = state.copyWith(
        contacts: contacts,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: '加载客户联系方式失败: $e',
      );
    }
  }

  Future<void> addContact(ContactInfo contact) async {
    state = state.copyWith(isLoading: true);
    try {
      final updatedContacts = [...state.contacts, contact.copyWith(id: DateTime.now().millisecondsSinceEpoch)];
      await contactInfoBox.put('contact_infos', updatedContacts.map((c) => c.toJson()).toList());
      state = state.copyWith(
        contacts: updatedContacts,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: '添加客户联系方式失败: $e',
      );
    }
  }

  Future<void> updateContact(ContactInfo contact) async {
    state = state.copyWith(isLoading: true);
    try {
      final updatedContacts = state.contacts.map((c) => c.id == contact.id ? contact : c).toList();
      await contactInfoBox.put('contact_infos', updatedContacts.map((c) => c.toJson()).toList());
      state = state.copyWith(
        contacts: updatedContacts,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: '更新客户联系方式失败: $e',
      );
    }
  }

  Future<void> deleteContact(int id) async {
    state = state.copyWith(isLoading: true);
    try {
      final updatedContacts = state.contacts.where((c) => c.id != id).toList();
      await contactInfoBox.put('contact_infos', updatedContacts.map((c) => c.toJson()).toList());
      state = state.copyWith(
        contacts: updatedContacts,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: '删除客户联系方式失败: $e',
      );
    }
  }
}

final contactInfoBoxProvider = Provider<Box>((ref) {
  return Hive.box('contact_info_box');
});

final contactInfoProvider = StateNotifierProvider<ContactInfoNotifier, ContactInfoState>((ref) {
  final box = ref.watch(contactInfoBoxProvider);
  return ContactInfoNotifier(box);
});
