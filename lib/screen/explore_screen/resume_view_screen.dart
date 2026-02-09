import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stakBread/screen/explore_screen/explore_tab_controller.dart';
import 'package:stakBread/utilities/color_res.dart';
import 'package:stakBread/utilities/text_style_custom.dart';

/// Resume view screen shown when user taps "View Resume" on a creator card.
/// Displays a dark app bar and a white card with name, title, summary, skills, work experience.
class ResumeViewScreen extends StatelessWidget {
  final ExploreCreatorItem creator;

  const ResumeViewScreen({super.key, required this.creator});

  static const String _defaultTitle = 'resume-doc-pdf';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorRes.whitePure,
      appBar: AppBar(
        backgroundColor: ColorRes.whitePure,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: ColorRes.blackPure, size: 22),
          onPressed: () => Get.back(),
        ),
        title: Text(
          _defaultTitle,
          style: TextStyleCustom.outFitSemiBold600(
            fontSize: 16,
            color: ColorRes.blackPure,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert, color: ColorRes.blackPure, size: 24),
            onPressed: () => _showResumeMenu(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: ColorRes.whitePure,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: _ResumeContent(creator: creator),
        ),
      ),
    );
  }

  void _showResumeMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: ColorRes.whitePure,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.download_rounded, color: ColorRes.textDarkGrey),
                title: Text('Download', style: TextStyleCustom.outFitRegular400(color: ColorRes.textDarkGrey)),
                onTap: () {
                  Get.back();
                },
              ),
              ListTile(
                leading: const Icon(Icons.share_rounded, color: ColorRes.textDarkGrey),
                title: Text('Share', style: TextStyleCustom.outFitRegular400(color: ColorRes.textDarkGrey)),
                onTap: () {
                  Get.back();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ResumeContent extends StatelessWidget {
  final ExploreCreatorItem creator;

  const _ResumeContent({required this.creator});

  @override
  Widget build(BuildContext context) {
    final data = _ResumeData.forCreator(creator);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          data.name,
          style: TextStyleCustom.outFitBold700(
            fontSize: 22,
            color: ColorRes.textDarkGrey,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          data.title,
          style: TextStyleCustom.outFitRegular400(
            fontSize: 15,
            color: ColorRes.textDarkGrey,
          ),
        ),
        const SizedBox(height: 20),
        _SectionHeading(title: 'Professional Summary'),
        const SizedBox(height: 8),
        Text(
          data.summary,
          style: TextStyleCustom.outFitRegular400(
            fontSize: 14,
            color: ColorRes.textDarkGrey,
          ),
        ),
        const SizedBox(height: 20),
        _SectionHeading(title: 'Skills'),
        const SizedBox(height: 8),
        ...data.skills.map((s) => _BulletItem(text: s)),
        const SizedBox(height: 20),
        _SectionHeading(title: 'Work Experience'),
        const SizedBox(height: 8),
        ...data.experience.expand((job) => [
              Text(
                job.title,
                style: TextStyleCustom.outFitMedium500(
                  fontSize: 14,
                  color: ColorRes.textDarkGrey,
                ),
              ),
              const SizedBox(height: 6),
              ...job.bullets.map((b) => _BulletItem(text: b)),
              const SizedBox(height: 14),
            ]),
      ],
    );
  }
}

class _SectionHeading extends StatelessWidget {
  final String title;

  const _SectionHeading({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: TextStyleCustom.outFitBold700(
        fontSize: 16,
        color: ColorRes.textDarkGrey,
      ),
    );
  }
}

class _BulletItem extends StatelessWidget {
  final String text;

  const _BulletItem({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 7),
            child: Container(
              width: 5,
              height: 5,
              decoration: const BoxDecoration(
                color: ColorRes.textDarkGrey,
                shape: BoxShape.circle,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: TextStyleCustom.outFitRegular400(
                fontSize: 14,
                color: ColorRes.textDarkGrey,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ResumeData {
  final String name;
  final String title;
  final String summary;
  final List<String> skills;
  final List<_JobEntry> experience;

  _ResumeData({
    required this.name,
    required this.title,
    required this.summary,
    required this.skills,
    required this.experience,
  });

  static _ResumeData forCreator(ExploreCreatorItem creator) {
    if (creator.id == 'c1' || creator.name == 'Cara Lee') {
      return _ResumeData(
        name: 'Cara Lee',
        title: 'Digital Content Creator & Marketing Specialist',
        summary:
            'Creative professional with 5+ years of experience in digital content creation and marketing. '
            'Specialized in developing engaging short-form video content and social media strategies that drive brand awareness and audience growth. '
            'Proven track record of collaborating with lifestyle, beauty, and tech brands to deliver impactful campaigns.',
        skills: [
          'Content Creation (Video, Reels, Short-Form Content)',
          'Social Media Marketing & Strategy',
          'Brand Storytelling & Visual Design',
          'Influencer & Community Engagement',
          'Campaign Planning & Execution',
          'Analytics & Performance Tracking',
          'Copywriting & Caption Writing',
        ],
        experience: [
          _JobEntry(
            title: 'Digital Content Creator Freelance',
            bullets: [
              'Created high-quality digital content for brands across lifestyle, beauty, and tech niches.',
              'Developed short-form video content optimized for Instagram, TikTok, and YouTube.',
              'Increased audience engagement through consistent content strategies.',
            ],
          ),
          _JobEntry(
            title: 'Marketing Specialist Creative Agency / Brand Collaboration',
            bullets: [
              'Planned and executed digital marketing campaigns for multiple clients.',
              'Managed influencer partnerships and community engagement initiatives.',
              'Analyzed campaign performance and provided data-driven recommendations.',
            ],
          ),
        ],
      );
    }
    return _ResumeData(
      name: creator.name,
      title: creator.profession,
      summary:
          'Experienced professional with a strong background in ${creator.profession.toLowerCase()}. '
          'Dedicated to delivering high-quality work and driving results.',
      skills: [
        'Relevant skill 1',
        'Relevant skill 2',
        'Relevant skill 3',
      ],
      experience: [
        _JobEntry(
          title: '${creator.profession} – Previous Role',
          bullets: [
            'Key responsibility or achievement.',
            'Another key point.',
          ],
        ),
      ],
    );
  }
}

class _JobEntry {
  final String title;
  final List<String> bullets;

  _JobEntry({required this.title, required this.bullets});
}
