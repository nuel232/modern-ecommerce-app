import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:morden_ecommerce_app/services/theme/theme_provider.dart';
import 'package:provider/provider.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.transparent),
      body: Center(
        child: Column(
          children: [
            //icon
            CircleAvatar(
              backgroundColor: Theme.of(context).colorScheme.secondary,
              radius: 70,
              child: Icon(
                CupertinoIcons.settings,
                size: 70,
                color: Theme.of(context).colorScheme.surface,
              ),
              // color: Colors.white,
            ),

            SizedBox(height: 20),

            Text(
              'Settings',
              style: TextStyle(
                fontSize: 35,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),

            SizedBox(height: 10),
            Container(
              margin: EdgeInsets.all(20),
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  ListTile(
                    leading: Icon(Icons.menu, size: 25),
                    title: Text('Manage Chat'),
                  ),
                  SizedBox(height: 10),

                  ListTile(
                    leading: Icon(Icons.file_upload_outlined, size: 25),
                    title: Text('Export Chat'),
                  ),

                  SizedBox(height: 10),

                  ListTile(
                    leading: Icon(Icons.color_lens_outlined, size: 25),
                    title: Text('Dark mode'),
                    trailing: CupertinoSwitch(
                      value: Provider.of<ThemeProvider>(
                        context,
                        listen: false,
                      ).isLightMode,
                      onChanged: (value) => Provider.of<ThemeProvider>(
                        context,
                        listen: false,
                      ).toggleTheme(),
                    ),
                  ),

                  SizedBox(height: 10),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
