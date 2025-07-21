class SupabaseConfig {
  // TODO: Replace with your actual Supabase project URL and anon key
  // Get these from: https://app.supabase.com/project/YOUR_PROJECT/settings/api
  static const String supabaseUrl = 'https://ltbwpbkblwhakhzxxpnw.supabase.co';
  static const String supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imx0YndwYmtibHdoYWtoenh4cG53Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTMxMjA1MjgsImV4cCI6MjA2ODY5NjUyOH0.3Hx26T0P5Kd4uCRIFuh2S8LfFVqo_o1rgixgFhy2XUM';
  
  // Storage bucket name for recipe images
  static const String recipeImagesBucket = 'recipe-images';
  
  // Image upload settings
  static const int maxFileSizeBytes = 5 * 1024 * 1024; // 5MB
  static const List<String> allowedExtensions = ['jpg', 'jpeg', 'png', 'webp'];
}
