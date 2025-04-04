-- Database Schema Updates (April 2024)

-- Remove special placeholder value handling for standalone items
-- Instead, ensure all items must have a valid pallet reference

-- 1. First, identify any items with the placeholder NO_PALLET_UUID value
CREATE OR REPLACE FUNCTION migrate_standalone_items()
RETURNS void AS $$
DECLARE
    standalone_count INTEGER;
    new_pallet_id UUID;
    standalone_pallet_exists BOOLEAN;
BEGIN
    -- Count items with the placeholder pallet ID
    SELECT COUNT(*) INTO standalone_count
    FROM public.items
    WHERE pallet_id = '00000000-0000-0000-0000-000000000000';
    
    -- If there are standalone items, we need to migrate them
    IF standalone_count > 0 THEN
        -- Check if a "Standalone Items" pallet already exists for each user
        PERFORM user_id, COUNT(*)
        FROM public.pallets
        WHERE name = 'Standalone Items'
        GROUP BY user_id
        HAVING COUNT(*) > 0;
        
        -- For users that have standalone items but no standalone pallet,
        -- create a special pallet to hold them
        INSERT INTO public.pallets (
            id, 
            user_id, 
            name, 
            type, 
            status, 
            purchase_date,
            purchase_cost,
            created_at, 
            updated_at
        )
        SELECT 
            gen_random_uuid(),
            items.user_id,
            'Standalone Items',
            'other',
            'in_progress',
            CURRENT_DATE,
            0.00,
            NOW(),
            NOW()
        FROM 
            public.items 
        WHERE 
            pallet_id = '00000000-0000-0000-0000-000000000000'
        AND 
            NOT EXISTS (
                SELECT 1 
                FROM public.pallets 
                WHERE pallets.user_id = items.user_id 
                AND pallets.name = 'Standalone Items'
            )
        GROUP BY 
            items.user_id;
        
        -- Update standalone items to point to their respective user's "Standalone Items" pallet
        UPDATE public.items i
        SET pallet_id = p.id
        FROM public.pallets p
        WHERE i.pallet_id = '00000000-0000-0000-0000-000000000000'
        AND p.user_id = i.user_id
        AND p.name = 'Standalone Items';
    END IF;
END;
$$ LANGUAGE plpgsql;

-- Execute the migration
SELECT migrate_standalone_items();

-- Drop the migration function when done
DROP FUNCTION migrate_standalone_items();

-- 2. Update the items table constraints to prevent null pallet_id values
ALTER TABLE public.items
ALTER COLUMN pallet_id SET NOT NULL;

-- 3. Add an index to speed up queries that filter by pallet_id
CREATE INDEX IF NOT EXISTS idx_items_pallet_id ON public.items(pallet_id);

-- 4. Add trigger to prevent creating items without a valid pallet
CREATE OR REPLACE FUNCTION ensure_valid_pallet_id()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.pallet_id IS NULL OR NEW.pallet_id = '00000000-0000-0000-0000-000000000000' THEN
        RAISE EXCEPTION 'Items must have a valid pallet ID';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_ensure_valid_pallet_id
BEFORE INSERT OR UPDATE ON public.items
FOR EACH ROW
EXECUTE FUNCTION ensure_valid_pallet_id();

-- 5. Update pallet type enum if needed
-- This is only necessary if the types don't match what's used in the code
-- DO $$
-- BEGIN
--     IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'pallet_status_new') THEN
--         CREATE TYPE pallet_status_new AS ENUM ('in_progress', 'processed', 'archived');
--         
--         -- Migrate data
--         ALTER TABLE public.pallets
--         ALTER COLUMN status TYPE pallet_status_new 
--         USING (
--             CASE status::text
--                 WHEN 'active' THEN 'in_progress'::pallet_status_new
--                 WHEN 'processing' THEN 'in_progress'::pallet_status_new
--                 ELSE status::text::pallet_status_new
--             END
--         );
--         
--         -- Drop old type
--         DROP TYPE pallet_status;
--         
--         -- Rename new type to old name
--         ALTER TYPE pallet_status_new RENAME TO pallet_status;
--     END IF;
-- END
-- $$; 