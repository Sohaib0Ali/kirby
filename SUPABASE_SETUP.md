# Supabase Setup Guide for Kirby Warranty Claims App

## 📋 Required Supabase Values

You need to obtain these values from your Supabase project and add them to the `.env` file:

### 1. SUPABASE_URL
- **What it is**: Your Supabase project URL
- **Format**: `https://your-project-id.supabase.co`
- **Where to find it**: Supabase Dashboard → Settings → API

### 2. SUPABASE_ANON_KEY
- **What it is**: Your project's anonymous/public API key
- **Format**: Long JWT token starting with `eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...`
- **Where to find it**: Supabase Dashboard → Settings → API → Project API keys → `anon public`

## 🚀 How to Get These Values

### Step 1: Create a Supabase Project
1. Go to [supabase.com](https://supabase.com)
2. Sign up/Login to your account
3. Click "New Project"
4. Choose your organization
5. Enter project name: `kirby-warranty-claims`
6. Enter database password (save this!)
7. Select region closest to you
8. Click "Create new project"

### Step 2: Get Your Project Credentials
1. Wait for project to be created (2-3 minutes)
2. Go to **Settings** → **API** in the left sidebar
3. Copy the **Project URL** (this is your `SUPABASE_URL`)
4. Copy the **anon public** key (this is your `SUPABASE_ANON_KEY`)

### Step 3: Update Your .env File
Open the `.env` file in your project root and replace the placeholder values:

```env
# Replace these with your actual Supabase credentials
SUPABASE_URL=https://your-actual-project-id.supabase.co
SUPABASE_ANON_KEY=your-actual-anon-key-here
```

## 🗄️ Required Database Tables

Create these tables in your Supabase database:

### 1. warranty_claims Table

```sql
-- Create warranty_claims table
CREATE TABLE warranty_claims (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    product_name VARCHAR(255) NOT NULL,
    customer_name VARCHAR(255) NOT NULL,
    customer_email VARCHAR(255) NOT NULL,
    claim_status VARCHAR(50) DEFAULT 'pending' CHECK (claim_status IN ('pending', 'approved', 'rejected')),
    description TEXT NOT NULL,
    serial_number VARCHAR(100),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create updated_at trigger
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER update_warranty_claims_updated_at 
    BEFORE UPDATE ON warranty_claims 
    FOR EACH ROW 
    EXECUTE FUNCTION update_updated_at_column();

-- Enable Row Level Security (RLS)
ALTER TABLE warranty_claims ENABLE ROW LEVEL SECURITY;

-- Create policy to allow all operations for authenticated users
CREATE POLICY "Allow all operations for authenticated users" ON warranty_claims
    FOR ALL USING (true);

-- Create policy to allow read access for anonymous users (for demo purposes)
CREATE POLICY "Allow read access for anonymous users" ON warranty_claims
    FOR SELECT USING (true);
```

### 2. Sample Data (Optional)

```sql
-- Insert sample warranty claims for testing
INSERT INTO warranty_claims (product_name, customer_name, customer_email, claim_status, description, serial_number) VALUES
('iPhone 14 Pro', 'John Doe', 'john.doe@email.com', 'pending', 'Screen cracked after dropping', 'IP14P123456'),
('MacBook Air M2', 'Jane Smith', 'jane.smith@email.com', 'approved', 'Battery not charging properly', 'MBA2023789'),
('iPad Pro 12.9', 'Mike Johnson', 'mike.j@email.com', 'rejected', 'Water damage not covered', 'IPP129456'),
('AirPods Pro 2', 'Sarah Wilson', 'sarah.w@email.com', 'pending', 'Left earbud not working', 'APP2024123'),
('Apple Watch Series 9', 'David Brown', 'david.b@email.com', 'approved', 'Crown button stuck', 'AWS9456789');
```

## 🔧 Setup Instructions

### Step 1: Run SQL Commands
1. Go to Supabase Dashboard → **SQL Editor**
2. Copy and paste the table creation SQL above
3. Click **Run** to create the table
4. Optionally, run the sample data SQL for testing

### Step 2: Update Environment Variables
1. Update your `.env` file with the actual values
2. Restart your Flutter app: `flutter run`

### Step 3: Test the Connection
1. The app will automatically try to connect to Supabase on startup
2. Check the console for any connection errors
3. The dashboard should display your warranty claims data

## 🔒 Security Notes

- The `anon` key is safe to use in client-side applications
- Row Level Security (RLS) is enabled for data protection
- For production, implement proper authentication and authorization policies
- Never commit your `.env` file to version control (it's already in `.gitignore`)

## 🐛 Troubleshooting

### Common Issues:

1. **"Supabase not initialized" error**
   - Check that your `.env` file has the correct values
   - Ensure the `.env` file is in the project root
   - Restart the app after updating `.env`

2. **"Table doesn't exist" error**
   - Make sure you've created the `warranty_claims` table in Supabase
   - Check the table name matches exactly: `warranty_claims`

3. **Connection timeout**
   - Verify your internet connection
   - Check if your Supabase project is active (not paused)
   - Confirm the project URL is correct

4. **No data showing**
   - Insert some sample data using the SQL provided above
   - Check the browser network tab for API errors
   - Verify RLS policies allow data access

## 📱 App Features

Once connected, your app will display:

- **Dashboard Stats**: Total, pending, approved, and rejected claims
- **Recent Claims**: Latest 5 warranty claims with status
- **Real-time Data**: Automatically fetches from your Supabase database
- **Professional UI**: Modern cards with animations and status indicators

## 🔄 Next Steps

After setup, you can:
1. Add more warranty claims through the Supabase dashboard
2. Implement claim creation forms in the app
3. Add user authentication
4. Create admin panels for claim management
5. Add file upload for claim attachments

---

**Need Help?** Check the Supabase documentation at [docs.supabase.com](https://docs.supabase.com) or the Flutter Supabase guide at [supabase.com/docs/guides/getting-started/tutorials/with-flutter](https://supabase.com/docs/guides/getting-started/tutorials/with-flutter)
