-- 1. Add permissions column to profiles
ALTER TABLE public.profiles 
ADD COLUMN IF NOT EXISTS permissions JSONB DEFAULT '{"inv_edit": false, "rcpt_gen": true, "users_view": false, "act_view": false, "acct_view": true, "worth_view": false, "rcpt_del": false}'::jsonb;

-- 2. Update Categories and Items Policies to allow staff with 'inv_edit' permission
DROP POLICY IF EXISTS "cats_write" ON public.categories;
CREATE POLICY "cats_write" ON public.categories
  FOR ALL USING (
    public.get_my_role() = 'admin' OR 
    (SELECT coalesce((permissions->>'inv_edit')::boolean, false) FROM public.profiles WHERE id = auth.uid())
  );

DROP POLICY IF EXISTS "items_write" ON public.items;
CREATE POLICY "items_write" ON public.items
  FOR ALL USING (
    public.get_my_role() = 'admin' OR 
    (SELECT coalesce((permissions->>'inv_edit')::boolean, false) FROM public.profiles WHERE id = auth.uid())
  );

-- 3. Update Sales update/delete to check for 'rcpt_del' permission (although admins can always do it)
DROP POLICY IF EXISTS "sales_update" ON public.sales;
CREATE POLICY "sales_update" ON public.sales
  FOR ALL USING (
    public.get_my_role() = 'admin' OR 
    (SELECT coalesce((permissions->>'rcpt_del')::boolean, false) FROM public.profiles WHERE id = auth.uid())
  );

-- Also add a delete policy specifically for sales (if not existing, "for all" above covers it, but explicitly for sale_items)
DROP POLICY IF EXISTS "si_all" ON public.sale_items;
CREATE POLICY "si_all" ON public.sale_items
  FOR ALL USING (
    public.get_my_role() = 'admin' OR 
    (SELECT coalesce((permissions->>'rcpt_del')::boolean, false) FROM public.profiles WHERE id = auth.uid())
  );

-- 4. Admin Update User Function (Postgres RPC) to allow admin to reset passwords and usernames securely
CREATE OR REPLACE FUNCTION public.admin_update_user(
    target_user_id UUID,
    new_username TEXT,
    new_password TEXT,
    new_full_name TEXT,
    new_permissions JSONB,
    new_role TEXT
)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
    -- 1. Verify caller is an admin
    IF (SELECT role FROM public.profiles WHERE id = auth.uid()) != 'admin' THEN
        RAISE EXCEPTION 'Only administrators can update user credentials.';
    END IF;

    -- 2. Update auth.users (email and password)
    IF new_username IS NOT NULL AND new_username != '' THEN
        UPDATE auth.users 
        SET email = new_username || '@pafwa.local'
        WHERE id = target_user_id;
    END IF;

    IF new_password IS NOT NULL AND new_password != '' THEN
        -- Uses the pgcrypto extension to hash the password exactly as Supabase GoTrue expects
        UPDATE auth.users 
        SET encrypted_password = crypt(new_password, gen_salt('bf'))
        WHERE id = target_user_id;
    END IF;

    -- 3. Update public.profiles (name, role, permissions)
    UPDATE public.profiles
    SET full_name = COALESCE(new_full_name, full_name),
        username = COALESCE(new_username, username),
        role = COALESCE(new_role, role),
        permissions = COALESCE(new_permissions, permissions)
    WHERE id = target_user_id;

END;
$$;
