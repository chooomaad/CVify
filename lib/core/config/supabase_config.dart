// ─── SUPABASE CONFIGURATION ──────────────────────────────────────────────────
//
// IMPORTANT : Remplacez ces valeurs par celles de votre projet Supabase.
// Tableau de bord Supabase → Settings → API
//
// SQL Schema à exécuter dans l'éditeur SQL Supabase :
//
// -- 1. Table profiles
// CREATE TABLE IF NOT EXISTS public.profiles (
//   id           UUID        REFERENCES auth.users ON DELETE CASCADE NOT NULL PRIMARY KEY,
//   email        TEXT        NOT NULL,
//   full_name    TEXT,
//   phone        TEXT,
//   bio          TEXT,
//   avatar_url   TEXT,
//   created_at   TIMESTAMPTZ DEFAULT NOW() NOT NULL,
//   updated_at   TIMESTAMPTZ DEFAULT NOW() NOT NULL
// );
//
// -- 2. Row Level Security
// ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
//
// CREATE POLICY "Lecture profil personnel" ON public.profiles
//   FOR SELECT USING (auth.uid() = id);
//
// CREATE POLICY "Insertion profil personnel" ON public.profiles
//   FOR INSERT WITH CHECK (auth.uid() = id);
//
// CREATE POLICY "Modification profil personnel" ON public.profiles
//   FOR UPDATE USING (auth.uid() = id);
//
// CREATE POLICY "Suppression profil personnel" ON public.profiles
//   FOR DELETE USING (auth.uid() = id);
//
// -- 3. Bucket Storage pour les avatars
// INSERT INTO storage.buckets (id, name, public)
//   VALUES ('avatars', 'avatars', true)
//   ON CONFLICT DO NOTHING;
//
// CREATE POLICY "Lecture publique avatars" ON storage.objects
//   FOR SELECT USING (bucket_id = 'avatars');
//
// CREATE POLICY "Upload avatar personnel" ON storage.objects
//   FOR INSERT WITH CHECK (
//     bucket_id = 'avatars'
//     AND auth.uid()::text = (storage.foldername(name))[1]
//   );
//
// CREATE POLICY "Mise à jour avatar personnel" ON storage.objects
//   FOR UPDATE USING (
//     bucket_id = 'avatars'
//     AND auth.uid()::text = (storage.foldername(name))[1]
//   );
//
// CREATE POLICY "Suppression avatar personnel" ON storage.objects
//   FOR DELETE USING (
//     bucket_id = 'avatars'
//     AND auth.uid()::text = (storage.foldername(name))[1]
//   );
//
// -- 4. Trigger pour auto-créer le profil à l'inscription
// CREATE OR REPLACE FUNCTION public.handle_new_user()
// RETURNS TRIGGER AS $$
// BEGIN
//   INSERT INTO public.profiles (id, email, full_name)
//   VALUES (
//     NEW.id,
//     NEW.email,
//     NEW.raw_user_meta_data ->> 'full_name'
//   )
//   ON CONFLICT (id) DO NOTHING;
//   RETURN NEW;
// END;
// $$ LANGUAGE plpgsql SECURITY DEFINER;
//
// CREATE OR REPLACE TRIGGER on_auth_user_created
//   AFTER INSERT ON auth.users
//   FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();
// ─────────────────────────────────────────────────────────────────────────────

class SupabaseConfig {
  // ⬇ Remplacez par votre URL Supabase (ex: https://abcxyz.supabase.co)
  static const String url = 'https://hyzrlxoowgzuetoxrjlv.supabase.co';

  // ⬇ Remplacez par votre clé anonyme publique (anon key)
  static const String anonKey = 'sb_publishable_K7asq4GbTTQsSrFFcwUslg_XzsVSAiF';

  // Schéma URL pour les deep links (email confirmation, reset password)
  static const String authRedirectScheme = 'io.cvify.app';
  static const String authRedirectUrl = '$authRedirectScheme://auth-callback';
  static const String passwordResetUrl = '$authRedirectScheme://reset-password';

  static const String avatarsBucket = 'avatars';
  static const String profilesTable = 'profiles';
}
