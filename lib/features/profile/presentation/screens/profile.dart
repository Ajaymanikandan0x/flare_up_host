import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/constants.dart';
import '../../../../core/routes/routs.dart';
import '../../../../core/theme/text_theme.dart';
import '../../../../core/utils/image_picker_service.dart';
import '../../../../core/utils/responsive_utils.dart';
import '../../../../core/widgets/circle_vatar.dart';
import '../bloc/host_profile_bloc.dart';
import '../widgets/name_list_title.dart';
import '../widgets/profile_shimmer.dart';


class HostProfile extends StatelessWidget {
  const HostProfile({super.key});

  @override
  Widget build(BuildContext context) {
    // Initialize responsive utilities
    Responsive.init(context);

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'Edit Profile',
          style: AppTextStyles.primaryTextTheme(
            fontSize: Responsive.titleFontSize,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () async {
              final state = context.read<HostProfileBloc>().state;
              if (state is HostProfileLoaded) {
                Navigator.pop(context);
              }
            },
            child: Text(
              'Done',
              style: AppTextStyles.primaryTextTheme(
                fontSize: Responsive.bodyFontSize,
              ),
            ),
          )
        ],
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: Responsive.horizontalPadding,
          vertical: Responsive.verticalPadding,
        ),
        child: BlocConsumer<HostProfileBloc, HostProfileState>(
          listener: (context, state) {
            if (state is HostProfileError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message)),
              );
            } else if (state is ProfileImageUploadSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Profile image updated successfully')),
              );
            }
          },
          builder: (context, state) {
            if (state is HostProfileLoading || 
                state is HostProfileInitial || 
                state is ProfileImageUploading) {
              return const ProfileShimmer();
            }
            
            if (state is HostProfileLoaded) {
              final user = state.user;
              return Column(
                children: [
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      Avatar(
                        radius: Responsive.imageSize,
                        imgUrl: user.profileImage,
                      ),
                      if (state is ProfileImageUploading)
                        const CircularProgressIndicator(),
                    ],
                  ),
                  SizedBox(height: Responsive.spacingHeight),
                  TextButton(
                    onPressed: () async {
                      File? imageFile = await ImagePickerService.pickImageFromGallery();
                      if (imageFile != null) {
                        context.read<HostProfileBloc>().add(UploadProfileImage(imageFile));
                      }
                    },
                    child: Text(
                      'Change Profile Photo',
                      style: AppTextStyles.primaryTextTheme(
                        fontSize: Responsive.subtitleFontSize,
                      ),
                    )
                  ),
                  SizedBox(height: Responsive.spacingHeight * 2),
                  NameListTile(
                    leading: 'UserName',
                    title: user.username,
                    onTap: () {
                      Navigator.pushNamed(context, AppRouts.editProf,
                          arguments: {
                            'field': user.username,
                            'fieldType': 'UserName'
                          });
                    }),
                  minHeight,
                  NameListTile(
                    leading: 'FullName',
                    title: user.fullName,
                    onTap: () {
                      Navigator.pushNamed(context, AppRouts.editProf,
                          arguments: {
                            'field': user.fullName,
                            'fieldType': 'FullName'
                          });
                    }),
                  minHeight,
                  Text(
                    'Private Information',
                    style: AppTextStyles.primaryTextTheme(
                      fontSize: Responsive.subtitleFontSize,
                    ),
                  ),
                  SizedBox(height: Responsive.spacingHeight),
                  NameListTile(
                    leading: 'Email',
                    title: user.email,
                    onTap: () {
                      Navigator.pushNamed(context, AppRouts.editProf,
                          arguments: {
                            'field': user.email,
                            'fieldType': 'Email'
                          });
                    }),
                  minHeight,
                  NameListTile(
                    leading: 'Phone',
                    title: user.phoneNumber ?? 'Not set',
                    onTap: () {
                      Navigator.pushNamed(context, AppRouts.editProf,
                          arguments: {
                            'field': user.phoneNumber ?? '',
                            'fieldType': 'PhoneNumber'
                          });
                    }),
                  minHeight,
                  NameListTile(
                    leading: 'Role',
                    title: user.role,
                    onTap: () {},
                  ),
                ],
              );
            } else if (state is HostProfileError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Error: ${state.message}'),
                    ElevatedButton(
                      onPressed: () => Navigator.pushReplacementNamed(
                        context, 
                        AppRouts.signIn
                      ),
                      child: const Text('Return to Login'),
                    ),
                  ],
                ),
              );
            }
            return const Center(child: CircularProgressIndicator());
          },
        ),
      ),
    );
  }
}
