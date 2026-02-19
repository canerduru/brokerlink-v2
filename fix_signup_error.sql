-- ============================================================
-- FIX: "Database error saving new user" (Signup 500 Error)
-- Run this entire script in Supabase SQL Editor
-- ============================================================

-- STEP 1: Drop any existing broken trigger
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;

-- STEP 2: Create/Replace the profiles auto-creation function
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS trigger AS $$
BEGIN
  INSERT INTO public.profiles (id, name, email)
  VALUES (
    NEW.id,
    COALESCE(
      NEW.raw_user_meta_data->>'name',
      split_part(NEW.email, '@', 1)
    ),
    NEW.email
  )
  ON CONFLICT (id) DO NOTHING;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- STEP 3: Re-create the trigger
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- STEP 4: Make sure profiles.email is nullable (in case it has NOT NULL constraint)
ALTER TABLE public.profiles ALTER COLUMN email DROP NOT NULL;

-- STEP 5: Verify trigger was created
SELECT trigger_name, event_manipulation, action_statement
FROM information_schema.triggers
WHERE event_object_table = 'users'
AND trigger_schema = 'auth';
