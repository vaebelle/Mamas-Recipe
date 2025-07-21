import 'package:flutter/cupertino.dart';
import '../services/image_upload_service.dart';
import '../config/supabase_config.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseTestScreen extends StatefulWidget {
  const SupabaseTestScreen({super.key});

  @override
  State<SupabaseTestScreen> createState() => _SupabaseTestScreenState();
}

class _SupabaseTestScreenState extends State<SupabaseTestScreen> {
  String _status = 'Ready to test';
  bool _isLoading = false;

  Future<void> _testSupabaseConnection() async {
    setState(() {
      _isLoading = true;
      _status = 'Testing Supabase connection...';
    });

    try {
      // Test 1: Check if Supabase is initialized
      final supabase = Supabase.instance.client;
      setState(() {
        _status = '✅ Supabase client initialized\n';
      });

      // Test 2: Check storage bucket access
      try {
        await supabase.storage.listBuckets();
        setState(() {
          _status += '✅ Storage access working\n';
        });
      } catch (e) {
        setState(() {
          _status += '❌ Storage access failed: $e\n';
        });
      }

      // Test 3: Check if bucket exists
      try {
        await supabase.storage.from(SupabaseConfig.recipeImagesBucket).list();
        setState(() {
          _status += '✅ Recipe images bucket accessible\n';
        });
      } catch (e) {
        setState(() {
          _status += '❌ Recipe images bucket not found: $e\n';
        });
      }

      setState(() {
        _status += '\n🎉 Connection test complete!';
      });

    } catch (e) {
      setState(() {
        _status = '❌ Connection failed: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _testImagePicker() async {
    setState(() {
      _isLoading = true;
      _status = 'Testing image picker...';
    });

    try {
      final image = await ImageUploadService.showImagePickerDialog();
      if (image != null) {
        setState(() {
          _status = '✅ Image selected: ${image.name}\nSize: ${image.path}';
        });
      } else {
        setState(() {
          _status = 'No image selected';
        });
      }
    } catch (e) {
      setState(() {
        _status = '❌ Image picker failed: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Supabase Test'),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),
              const Text(
                'Supabase Integration Test',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),
              
              // Test Connection Button
              CupertinoButton.filled(
                onPressed: _isLoading ? null : _testSupabaseConnection,
                child: const Text('Test Supabase Connection'),
              ),
              
              const SizedBox(height: 10),
              
              // Test Image Picker Button
              CupertinoButton.filled(
                onPressed: _isLoading ? null : _testImagePicker,
                child: const Text('Test Image Picker'),
              ),
              
              const SizedBox(height: 30),
              
              // Status Display
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: CupertinoColors.systemGrey6,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Test Results:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),
                      if (_isLoading)
                        const Center(child: CupertinoActivityIndicator())
                      else
                        Expanded(
                          child: SingleChildScrollView(
                            child: Text(_status),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 20),
              
              // Configuration Info
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: CupertinoColors.systemYellow.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: CupertinoColors.systemYellow),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '⚠️ Configuration Check:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text('URL: ${SupabaseConfig.supabaseUrl}'),
                    Text('Bucket: ${SupabaseConfig.recipeImagesBucket}'),
                    const SizedBox(height: 8),
                    const Text(
                      'Make sure to update supabase_config.dart with your actual project details!',
                      style: TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
