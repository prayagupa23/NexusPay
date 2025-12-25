import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseConfig {
  static const String supabaseUrl = 'https://ucynrscpxkslgpjmndth.supabase.co';
  static const String supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InVjeW5yc2NweGtzbGdwam1uZHRoIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjY0NzM0MDEsImV4cCI6MjA4MjA0OTQwMX0.w1FnUFhv6C_mq249BL4beMAAx-VYox1p61OURwpuQXs';

  static Future<void> initialize() async {
    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
    );
  }

  static SupabaseClient get client => Supabase.instance.client;
}

