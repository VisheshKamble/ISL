// lib/l10n/AppLocalizations.dart
import 'package:flutter/material.dart';

class AppLocalizations {
  final Locale locale;
  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static const List<Locale> supportedLocales = [
    Locale('en'),
    Locale('hi'),
    Locale('mr'),
  ];

  static const Map<String, Map<String, String>> _localizedValues = {
    // ═══════════════════════════════════════════════════
    //  ENGLISH
    // ═══════════════════════════════════════════════════
    'en': {
      // ── Navbar
      'nav_home': 'HOME',
      'nav_terminal': 'TERMINAL',
      'nav_api': 'API',
      'nav_language': 'Language',
      'nav_signs': 'SIGNS',

      // ── Badge
      'badge': 'Vani Vision — 18k+ Dataset Trained',

      // ── Hero
      'hero_title_1': 'Translate ',
      'hero_title_highlight': 'Sign Language ',
      'hero_title_2': 'To Text,\nIn Real-Time.',
      'hero_sub':
          'Empowering India\'s deaf & mute community through on-device AI.\nBuilt for accuracy. Designed for dignity.',
      'get_started': 'Launch Terminal',

      // ── Stats
      'stat_mute_label': 'Deaf & Mute in India',
      'stat_isl_label': 'ISL Users',
      'stat_translators_label': 'Certified Translators',

      // ── Objectives grid
      'obj_heading': 'What We Stand For',
      'obj_sub': 'Built with purpose. Designed for impact.',
      'obj_accessibility': 'Accessibility',
      'obj_accessibility_desc': 'Breaking communication barriers for all',
      'obj_bridging': 'Bridging Gaps',
      'obj_bridging_desc': 'Connecting deaf & hearing communities',
      'obj_inclusivity': 'Inclusivity',
      'obj_inclusivity_desc': 'A digital world that speaks every language',
      'obj_privacy': 'Privacy First',
      'obj_privacy_desc': '100% on-device — your data never leaves',
      'obj_offline': 'Offline Ready',
      'obj_offline_desc': 'Works anywhere, even without internet',
      'obj_education': 'Education',
      'obj_education_desc': 'Learn ISL through real-time AI feedback',

      // ── Vision
      'vision_title': 'Empowering Silence with Vani AI',
      'vision_body':
          'With only 1 certified translator for every 33,000+ deaf & mute individuals in India, Vani bridges the gap — delivering real-time sign language translation directly on your device, privately and accurately.',

      // ── Translate Screen
      'translate_vision_title': 'AI VISION STREAM',
      'translate_vision_sub': 'Processing real-time sign language data',
      'translate_prediction': 'REAL-TIME PREDICTION',
      'translate_waiting': 'Waiting...',
      'translate_transcription': 'TRANSCRIPTION',
      'translate_hint': 'Captured signs will appear here...',
      'translate_start': 'Start Capturing',
      'translate_switch': 'Switch',
      'translate_cam_on': 'ON',
      'translate_cam_off': 'OFF',

      // ── Dialog
      'dialog_title': 'VANI CORE READY',
      'dialog_body':
          'Initialize the AI module by toggling the camera. Ensure your hands are visible within the capture frame for accurate real-time translation.',
      'dialog_btn': 'INITIALIZE MODULE',

      // ── Language names
      'lang_en': 'English',
      'lang_hi': 'हिन्दी',
      'lang_mr': 'मराठी',

      // ── Shared objective page UI
      'obj_page_back': 'Back to Home',
      'obj_page_explore': 'Explore →',
      'obj_page_confidence': 'Confidence',
      'obj_crisis_stat': '1 translator : 33,000+ people',
      'obj_quote_icon_label': 'Quote',

      // ══════════════════════════════════════════
      //  SIGNS PAGE
      // ══════════════════════════════════════════
      'signs_title_1': 'ISL ',
      'signs_title_highlight': 'Signs Library',
      'signs_subtitle':
          'Explore all 64 Indian Sign Language signs supported by Vani. Tap or hover any card to reveal the hand shape, meaning, and usage description.',

      // Stats pills
      'signs_stat_total':    'Total Signs',
      'signs_stat_alphabet': 'Alphabet',
      'signs_stat_numbers':  'Numbers',
      'signs_stat_words':    'Words',

      // Search & filter
      'signs_search_hint': 'Search signs by name, meaning or category…',
      'cat_all':            'All',
      'cat_alphabet':       'Alphabet',
      'cat_numbers':        'Numbers',
      'cat_words':          'Words',

      // Count row
      'signs_showing_all':      'Showing all {n} signs',
      'signs_showing_filtered': 'Showing {n} of {total} signs',

      // Empty state
      'signs_no_results':     'No signs found',
      'signs_no_results_sub': 'Try adjusting your search or filter',

      // ── ALPHABET SIGNS ─────────────────────────
      'sign_a_name': 'Letter A',
      'sign_a_meaning': 'The letter A',
      'sign_a_desc': 'Closed fist with thumb resting against the side of the index finger.',

      'sign_b_name': 'Letter B',
      'sign_b_meaning': 'The letter B',
      'sign_b_desc': 'All four fingers held straight up together, thumb folded across the palm.',

      'sign_c_name': 'Letter C',
      'sign_c_meaning': 'The letter C',
      'sign_c_desc': 'Hand curved into a C shape, all fingers curved and thumb aligned opposite.',

      'sign_d_name': 'Letter D',
      'sign_d_meaning': 'The letter D',
      'sign_d_desc': 'Index finger pointing up, other fingers and thumb form a circle.',

      'sign_e_name': 'Letter E',
      'sign_e_meaning': 'The letter E',
      'sign_e_desc': 'All four fingers bent at mid-knuckle, thumb tucked under the fingers.',

      'sign_f_name': 'Letter F',
      'sign_f_meaning': 'The letter F',
      'sign_f_desc': 'Index finger and thumb touch to form a circle, other three fingers spread upward.',

      'sign_g_name': 'Letter G',
      'sign_g_meaning': 'The letter G',
      'sign_g_desc': 'Index finger and thumb extended parallel, pointing horizontally to the side.',

      'sign_h_name': 'Letter H',
      'sign_h_meaning': 'The letter H',
      'sign_h_desc': 'Index and middle fingers extended side-by-side horizontally, other fingers closed.',

      'sign_i_name': 'Letter I',
      'sign_i_meaning': 'The letter I',
      'sign_i_desc': 'Pinky finger extended upward, all other fingers and thumb closed in a fist.',

      'sign_j_name': 'Letter J',
      'sign_j_meaning': 'The letter J',
      'sign_j_desc': 'Pinky extended, trace a J curve in the air from top down and hook left.',

      'sign_k_name': 'Letter K',
      'sign_k_meaning': 'The letter K',
      'sign_k_desc': 'Index and middle fingers form a V, thumb rests between them pointing up.',

      'sign_l_name': 'Letter L',
      'sign_l_meaning': 'The letter L',
      'sign_l_desc': 'Index finger points up and thumb extends outward forming an L shape.',

      'sign_m_name': 'Letter M',
      'sign_m_meaning': 'The letter M',
      'sign_m_desc': 'Three fingers (index, middle, ring) folded over the thumb which is tucked in.',

      'sign_n_name': 'Letter N',
      'sign_n_meaning': 'The letter N',
      'sign_n_desc': 'Index and middle fingers folded over the thumb, pinky and ring finger closed.',

      'sign_o_name': 'Letter O',
      'sign_o_meaning': 'The letter O',
      'sign_o_desc': 'All fingers and thumb curved to meet at the tips, forming a round O.',

      'sign_p_name': 'Letter P',
      'sign_p_meaning': 'The letter P',
      'sign_p_desc': 'Index and middle fingers point downward, thumb extended, hand angled down.',

      'sign_q_name': 'Letter Q',
      'sign_q_meaning': 'The letter Q',
      'sign_q_desc': 'Index finger and thumb point downward forming a Q, other fingers closed.',

      'sign_r_name': 'Letter R',
      'sign_r_meaning': 'The letter R',
      'sign_r_desc': 'Index and middle fingers crossed over each other, both pointing upward.',

      'sign_s_name': 'Letter S',
      'sign_s_meaning': 'The letter S',
      'sign_s_desc': 'Closed fist with thumb crossed over the front of the curled fingers.',

      'sign_t_name': 'Letter T',
      'sign_t_meaning': 'The letter T',
      'sign_t_desc': 'Thumb tucked between index and middle finger within a closed fist.',

      'sign_u_name': 'Letter U',
      'sign_u_meaning': 'The letter U',
      'sign_u_desc': 'Index and middle fingers extended together and upward, remaining fingers closed.',

      'sign_v_name': 'Letter V',
      'sign_v_meaning': 'The letter V',
      'sign_v_desc': 'Index and middle fingers spread into a V (peace sign), palm facing outward.',

      'sign_w_name': 'Letter W',
      'sign_w_meaning': 'The letter W',
      'sign_w_desc': 'Index, middle and ring fingers spread upward forming a W, thumb holds pinky.',

      'sign_x_name': 'Letter X',
      'sign_x_meaning': 'The letter X',
      'sign_x_desc': 'Index finger bent into a hook shape, all other fingers and thumb closed.',

      'sign_y_name': 'Letter Y',
      'sign_y_meaning': 'The letter Y',
      'sign_y_desc': 'Thumb and pinky extended outward, index, middle and ring fingers closed.',

      'sign_z_name': 'Letter Z',
      'sign_z_meaning': 'The letter Z',
      'sign_z_desc': 'Index finger traces a Z shape in the air, starting top-left to bottom-right.',

      // ── NUMBER SIGNS ───────────────────────────
      'sign_0_name': 'Number 0',
      'sign_0_meaning': 'Zero',
      'sign_0_desc': 'All fingers and thumb meet at tips forming a flat O, similar to the letter O.',

      'sign_1_name': 'Number 1',
      'sign_1_meaning': 'One',
      'sign_1_desc': 'Index finger points straight up, all other fingers and thumb closed.',

      'sign_2_name': 'Number 2',
      'sign_2_meaning': 'Two',
      'sign_2_desc': 'Index and middle fingers extended up and apart in a V shape.',

      'sign_3_name': 'Number 3',
      'sign_3_meaning': 'Three',
      'sign_3_desc': 'Index, middle, and ring fingers extended upward, thumb and pinky closed.',

      'sign_4_name': 'Number 4',
      'sign_4_meaning': 'Four',
      'sign_4_desc': 'Four fingers extended upward and spread, thumb folded across the palm.',

      'sign_5_name': 'Number 5',
      'sign_5_meaning': 'Five',
      'sign_5_desc': 'All five fingers spread wide open, palm facing forward.',

      'sign_6_name': 'Number 6',
      'sign_6_meaning': 'Six',
      'sign_6_desc': 'Pinky and thumb touch at tips, other three fingers extended upward.',

      'sign_7_name': 'Number 7',
      'sign_7_meaning': 'Seven',
      'sign_7_desc': 'Ring finger and thumb touch at tips, other fingers extended upward.',

      'sign_8_name': 'Number 8',
      'sign_8_meaning': 'Eight',
      'sign_8_desc': 'Middle finger and thumb touch at tips, other fingers extended upward.',

      'sign_9_name': 'Number 9',
      'sign_9_meaning': 'Nine',
      'sign_9_desc': 'Index finger and thumb form a circle (like OK sign), other fingers up.',

      // ── WORD SIGNS ─────────────────────────────
      'sign_namaste_name': 'Namaste',
      'sign_namaste_meaning': 'Greetings / Respect',
      'sign_namaste_desc': 'Both palms pressed together at chest level, fingers pointing upward.',

      'sign_hello_name': 'Hello',
      'sign_hello_meaning': 'Hello / Greeting',
      'sign_hello_desc': 'Open palm raised to forehead level, then moved outward in a wave.',

      'sign_hi_name': 'Hi',
      'sign_hi_meaning': 'Hi / Casual greeting',
      'sign_hi_desc': 'Open hand raised and waved side to side at shoulder height.',

      'sign_howareyou_name': 'How are you?',
      'sign_howareyou_meaning': 'How are you?',
      'sign_howareyou_desc': 'Bent hand moves outward from chest, then index finger points toward the person.',

      'sign_quiet_name': 'Quiet / Silence',
      'sign_quiet_meaning': 'Quiet / Silence',
      'sign_quiet_desc': 'Index finger placed vertically over closed lips, held still.',

      'sign_thanks_name': 'Thank You',
      'sign_thanks_meaning': 'Thank you / Gratitude',
      'sign_thanks_desc': 'Flat open hand starts at chin and moves outward toward the other person.',

      'sign_food_name': 'Food / Eat',
      'sign_food_meaning': 'Food / Eating',
      'sign_food_desc': 'All fingertips bunched together and brought repeatedly toward the mouth.',

      'sign_iloveyou_name': 'I Love You',
      'sign_iloveyou_meaning': 'I love you',
      'sign_iloveyou_desc': 'Index finger, pinky, and thumb extended; middle and ring fingers closed.',

      'sign_brother_name': 'Brother',
      'sign_brother_meaning': 'Brother',
      'sign_brother_desc': 'L-handshape at forehead, then brought down to rest on the other L-hand.',

      'sign_father_name': 'Father / Dad',
      'sign_father_meaning': 'Father',
      'sign_father_desc': 'Open hand with thumb touching forehead, fingers spread upward.',

      'sign_mother_name': 'Mother / Mom',
      'sign_mother_meaning': 'Mother',
      'sign_mother_desc': 'Open hand with thumb touching chin, fingers spread upward.',

      'sign_water_name': 'Water',
      'sign_water_meaning': 'Water',
      'sign_water_desc': 'W handshape (three fingers) taps the chin twice.',

      'sign_what_name': 'What?',
      'sign_what_meaning': 'What? / Question',
      'sign_what_desc': 'Index finger waggles side to side in front of the body.',

      'sign_please_name': 'Please',
      'sign_please_meaning': 'Please / Request',
      'sign_please_desc': 'Open palm placed flat on chest and moves in a circular motion.',

      'sign_help_name': 'Help / SOS',
      'sign_help_meaning': 'Help / Emergency',
      'sign_help_desc': 'Flat hand placed under a closed fist, both hands raised upward together.',

      'sign_loud_name': 'Loud / Noise',
      'sign_loud_meaning': 'Loud / Noise',
      'sign_loud_desc': 'Index fingers point to ears, then both hands shake outward rapidly.',

      'sign_yours_name': 'Yours / You',
      'sign_yours_meaning': 'Yours / You',
      'sign_yours_desc': 'Index finger points directly toward the person being addressed.',

      'sign_sleeping_name': 'Sleeping',
      'sign_sleeping_meaning': 'Sleep / Sleeping',
      'sign_sleeping_desc': 'Open hand moves from above the head downward past the face, eyes closed.',

      'sign_name_name': 'Name',
      'sign_name_meaning': 'Name / What is your name?',
      'sign_name_desc': 'H handshape (two fingers) tapped horizontally on the other H handshape twice.',

      'sign_sorry_name': 'Sorry',
      'sign_sorry_meaning': 'Sorry / Apology',
      'sign_sorry_desc': 'Closed fist (A handshape) rubbed in a circular motion on the chest.',

      'sign_good_name': 'Good',
      'sign_good_meaning': 'Good / Well done',
      'sign_good_desc': 'Flat hand at lips, then moved forward and downward into the other open palm.',

      'sign_bad_name': 'Bad',
      'sign_bad_meaning': 'Bad / Wrong',
      'sign_bad_desc': 'Flat hand at lips, then flipped outward and downward quickly.',

      'sign_today_name': 'Today',
      'sign_today_meaning': 'Today / Now',
      'sign_today_desc': 'Y handshapes on both hands dropped downward from waist level simultaneously.',

      'sign_time_name': 'Time',
      'sign_time_meaning': 'Time / Clock',
      'sign_time_desc': 'Index finger taps the back of the wrist where a watch would be.',

      'sign_strong_name': 'Strong',
      'sign_strong_meaning': 'Strong / Powerful',
      'sign_strong_desc': 'C handshape at shoulder contracts forward into a fist, showing muscle.',

      'sign_love_name': 'Love',
      'sign_love_meaning': 'Love / Affection',
      'sign_love_desc': 'Both arms crossed over the chest, hands in fists at the shoulders.',

      'sign_bandaid_name': 'Doctor / Medical',
      'sign_bandaid_meaning': 'Doctor / Medical help',
      'sign_bandaid_desc': 'M handshape (three fingers) pressed against the inside wrist, like checking a pulse.',

      'sign_happy_name': 'Happy',
      'sign_happy_meaning': 'Happy / Joyful',
      'sign_happy_desc': 'Open flat hand brushes upward on the chest in a repeated circular motion.',

      // ══════════════════════════════════════════
      //  ACCESSIBILITY PAGE (01)
      // ══════════════════════════════════════════
      'acc_tag': '01',
      'acc_category': 'ACCESSIBILITY',
      'acc_title': 'Breaking\nCommunication\nBarriers',
      'acc_subtitle':
          'For 63 million deaf and hard-of-hearing Indians, every interaction with the hearing world requires a bridge that rarely exists. Vani is that bridge — instant, private, and on-device.',

      'acc_stat1_val': '63M+',
      'acc_stat1_label': 'Deaf & HoH in India',
      'acc_stat1_desc': 'Largest such population in the world',
      'acc_stat2_val': '5%',
      'acc_stat2_label': 'Children in School',
      'acc_stat2_desc': 'Enrolled in any form of education',
      'acc_stat3_val': '26%',
      'acc_stat3_label': 'Employment Rate',
      'acc_stat3_desc': 'DHH adults in active employment',
      'acc_stat4_val': '387',
      'acc_stat4_label': 'Deaf Schools',
      'acc_stat4_desc': 'For a population of 63 million',

      'acc_s1_title': 'The Accessibility Crisis',
      'acc_s1_c1_title': 'Communication is a Human Right — Denied Daily',
      'acc_s1_c1_body':
          'India\'s deaf and hard-of-hearing (DHH) community faces systemic exclusion from education, healthcare, employment, and civic life. With only 1 certified sign language interpreter for every 33,000+ users, most interactions happen without any qualified assistance — forcing dependence on family, written notes, or simply being ignored.',
      'acc_s1_c2_title': 'The Urban–Rural Divide',
      'acc_s1_c2_body':
          'Most of India\'s 387 deaf schools are concentrated in urban centres. Rural DHH children often travel long distances to school, or simply never attend. Families from Maharashtra, UP, and Tamil Nadu have relocated to cities just to access basic education for their children.',
      'acc_s1_c3_title': 'Healthcare Without Words',
      'acc_s1_c3_body':
          'Medical consultations without sign language support lead to misdiagnosis, delayed treatment, and in emergencies — life-threatening miscommunication. Vani\'s real-time translation can serve as a critical tool in clinics, hospitals, and pharmacies.',

      'acc_s2_title': 'Barriers Vani Directly Targets',
      'acc_bar1': 'Public transport & navigation',
      'acc_bar2': 'Healthcare communication',
      'acc_bar3': 'Workplace interactions',
      'acc_bar4': 'Government services access',
      'acc_bar5': 'Educational participation',
      'acc_bar6': 'Emergency services',

      'acc_s3_title': 'How Vani Breaks Barriers',
      'acc_s3_c1_title': 'On-Device, Zero Latency Translation',
      'acc_s3_c1_body':
          'Vani processes sign language frames entirely on-device using a trained model. No cloud round-trip means no delay — critical for real conversations. A DHH user can sign naturally and the hearing counterpart reads the output instantly.',
      'acc_s3_c2_title': 'No Interpreter Required',
      'acc_s3_c2_body':
          'Professional interpreters cost ₹800–₹2,500/hour and require advance booking. Vani democratizes access — a ₹0 tool on any Android/iOS device that works at the bank, at the doctor, or on a job interview.',
      'acc_quote':
          'Disability is not in the person — it\'s in the environment. When we remove barriers from the environment, the disability disappears.',
      'acc_quote_src':
          'SOCIAL MODEL OF DISABILITY — UN CONVENTION ON THE RIGHTS OF PERSONS WITH DISABILITIES',

      'acc_s4_title': 'Legal Framework in India',
      'acc_t1_year': '1992',
      'acc_t1_event':
          'Rehabilitation Council of India Act — First statutory body for disability rehabilitation',
      'acc_t2_year': '1995',
      'acc_t2_event':
          'Persons with Disabilities Act — Mandates equal opportunity and inclusive education',
      'acc_t3_year': '2015',
      'acc_t3_event':
          'ISLRTC established — Indian Sign Language Research & Training Centre created',
      'acc_t4_year': '2016',
      'acc_t4_event':
          'RPwD Act 2016 — Expanded disability definitions, 21 categories including deaf-blindness',
      'acc_t5_year': '2020',
      'acc_t5_event':
          'NEP 2020 — National Education Policy recommends ISL teaching across all schools',

      // ══════════════════════════════════════════
      //  BRIDGING GAPS PAGE (02)
      // ══════════════════════════════════════════
      'bridge_tag': '02',
      'bridge_category': 'BRIDGING GAPS',
      'bridge_title': 'Connecting\nDeaf & Hearing\nCommunities',
      'bridge_subtitle':
          'The gap between India\'s deaf and hearing communities is not one of language — it is one of infrastructure. Vani builds the real-time infrastructure that lets both worlds communicate fluently.',

      'bridge_stat1_val': '18M',
      'bridge_stat1_label': 'True DHH Population',
      'bridge_stat1_desc': 'Per NAD India — vs 5M in 2011 Census (undercounting)',
      'bridge_stat2_val': '73.9%',
      'bridge_stat2_label': 'Marginal Workers',
      'bridge_stat2_desc': 'DHH aged 15–59 in India',
      'bridge_stat3_val': '1:33K',
      'bridge_stat3_label': 'Interpreter Ratio',
      'bridge_stat3_desc': '1 certified translator per 33,000 users',
      'bridge_stat4_val': '300',
      'bridge_stat4_label': 'Deaf Schools',
      'bridge_stat4_desc': 'With ISL-tailored curriculum',

      'bridge_s1_title': 'Why the Gap Exists',
      'bridge_s1_c1_title': 'ISL Still Not an Official Language',
      'bridge_s1_c1_body':
          'Indian Sign Language is used by over 8 million people but has no constitutional recognition. This means it has no mandated place in government communication, public broadcasting, or judicial proceedings — creating a citizenship gap for every DHH Indian.',
      'bridge_s1_c2_title': 'Oralism vs. Sign Language in Schools',
      'bridge_s1_c2_body':
          'Most Indian deaf schools use "oralism" — teaching children to lip-read and speak rather than sign. This approach, widely rejected globally, forces DHH children to mimic hearing communication at the cost of natural language acquisition, confidence, and identity.',
      'bridge_s1_c3_title': 'The Stigma of Silence',
      'bridge_s1_c3_body':
          'Research found that families in Rajasthan, Maharashtra, UP, and Tamil Nadu were "ashamed of deafness" and sought to "fix" rather than accommodate their DHH children. This cultural stigma isolates deaf individuals from their own families — the first bridge that must be built.',

      'bridge_s2_title': 'Community Integration Data',
      'bridge_bar1': 'DHH with access to ISL interpretation',
      'bridge_bar2': 'DHH with smartphone access',
      'bridge_bar3': 'Hearing people knowing any sign language',
      'bridge_bar4': 'DHH in formal employment',
      'bridge_bar5': 'DHH with secondary+ education',

      'bridge_s3_title': 'Vani as a Bridge Protocol',
      'bridge_s3_c1_title': 'Two-Way Communication Layer',
      'bridge_s3_c1_body':
          'Vani creates a shared communication interface. A DHH person signs; the hearing person reads. The same screen that shows the output can be used for the hearing person to type back, creating a full dialogue loop without any intermediary.',
      'bridge_s3_c2_title': 'Employment Bridge',
      'bridge_s3_c2_body':
          'Research shows deaf employees have higher retention rates and superior concentration in data processing roles. With Vani, job interviews, workplace meetings, and client communications become possible — opening doors to India\'s IT and finance sector.',
      'bridge_quote':
          'The real gap is not between deaf and hearing people — it is between those who have communication tools and those who do not.',
      'bridge_quote_src': 'NATIONAL ASSOCIATION OF THE DEAF, INDIA',

      'bridge_s4_title': 'Bridge-Building Timeline',
      'bridge_t1_year': '2011',
      'bridge_t1_event':
          'ISLRTC established at IGNOU — First institutional bridge for ISL research and teacher training',
      'bridge_t2_year': '2017',
      'bridge_t2_event':
          'Government codifies ISL in dictionary format — 3,000+ signs documented for the first time',
      'bridge_t3_year': '2018',
      'bridge_t3_event':
          'ISLRTC publishes ISL dictionary — Formal lexicon created for standardization',
      'bridge_t4_year': '2023',
      'bridge_t4_event':
          'Cambridge University calls for ISL as official language — Global academic pressure mounts',
      'bridge_t5_year': '2026',
      'bridge_t5_event':
          'Vani AI — Real-time on-device ISL translation available to every smartphone user in India',

      // ══════════════════════════════════════════
      //  INCLUSIVITY PAGE (03)
      // ══════════════════════════════════════════
      'incl_tag': '03',
      'incl_category': 'INCLUSIVITY',
      'incl_title': 'A Digital World\nThat Speaks\nEvery Language',
      'incl_subtitle':
          'India has 121 major languages. It has zero officially recognized sign languages. True digital inclusivity means no Indian is left behind — regardless of whether they speak, sign, or type.',

      'incl_stat1_val': '121',
      'incl_stat1_label': 'Languages in India',
      'incl_stat1_desc': 'Spoken across the nation',
      'incl_stat2_val': '0',
      'incl_stat2_label': 'Official Sign Languages',
      'incl_stat2_desc': 'ISL has no constitutional status',
      'incl_stat3_val': '19%+',
      'incl_stat3_label': 'DHH Children Out-of-School',
      'incl_stat3_desc': '2014 Government survey',
      'incl_stat4_val': '₹23,000Cr',
      'incl_stat4_label': 'Assistive Device Market',
      'incl_stat4_desc': 'Projected value by 2030 (20% CAGR)',

      'incl_s1_title': 'What Inclusive India Looks Like',
      'incl_s1_c1_title': 'The Digital India Paradox',
      'incl_s1_c1_body':
          'India\'s Digital India programme has connected 900 million people to the internet. Yet for 63 million DHH citizens, most digital interfaces remain inaccessible — websites without captions, apps without sign support, and government portals that assume everyone can hear.',
      'incl_s1_c2_title': 'Public Transport & Daily Navigation',
      'incl_s1_c2_body':
          'Metro announcements, bus stop PA systems, railway platform updates, and airport gates all rely exclusively on audio. For a DHH traveller, navigating Indian public transport without assistance requires significant prior knowledge, guesswork, or dependence on strangers.',
      'incl_s1_c3_title': 'Television & Media Exclusion',
      'incl_s1_c3_body':
          'Advanced economies mandate sign language windows or captions on all news broadcasts. India has no such requirement. Breaking news, emergency alerts, election results — all reach the hearing population in real-time and the DHH population much later, if at all.',

      'incl_s2_title': 'Inclusivity Gaps by Sector',
      'incl_bar1': 'Digital services accessible to DHH',
      'incl_bar2': 'TV broadcasts with sign interpretation',
      'incl_bar3': 'Government offices with ISL support',
      'incl_bar4': 'Hospitals with sign-capable staff',
      'incl_bar5': 'Workplaces with DHH inclusion policies',
      'incl_bar6': 'Schools with ISL-trained teachers',

      'incl_s3_title': 'Vani\'s Inclusivity Architecture',
      'incl_s3_c1_title': 'Multilingual Output — Hindi, English, Marathi',
      'incl_s3_c1_body':
          'Vani outputs in the language the user needs. A DHH user in Maharashtra can sign in ISL and have the output in Marathi for a Marathi-speaking listener. Language inclusivity serves both communities simultaneously.',
      'incl_s3_c2_title': 'Designed for Low-End Devices',
      'incl_s3_c2_body':
          'India\'s average smartphone runs on 2GB RAM. Vani is optimized for edge inference — lightweight model weights, low memory footprint, and battery-efficient computation so it runs on a ₹8,000 smartphone as well as a flagship device.',
      'incl_quote':
          'Inclusive design is not about adding features for the disabled. It\'s about designing for the full range of human diversity — and in doing so, creating better products for everyone.',
      'incl_quote_src':
          'UN CONVENTION ON THE RIGHTS OF PERSONS WITH DISABILITIES — ARTICLE 9',

      'incl_s4_title': 'Global Inclusivity Benchmarks',
      'incl_t1_year': 'USA',
      'incl_t1_event':
          'ADA (1990) mandates sign language access in all federal services — 35 years ahead of India',
      'incl_t2_year': 'UK',
      'incl_t2_event':
          'BSL recognised as official language in 2022; Equality Act guarantees reasonable adjustments',
      'incl_t3_year': 'NZ',
      'incl_t3_event':
          'NZSL is one of three official languages — sign language education mandatory in schools',
      'incl_t4_year': 'IND',
      'incl_t4_event':
          'RPwD Act 2016 — progress made but ISL still lacks official status; NEP 2020 recommends ISL in schools',
      'incl_t5_year': '2030',
      'incl_t5_event':
          'India\'s assistive device market projected at ₹23,000 Cr — Vani contributes to this accessible future',

      // ══════════════════════════════════════════
      //  PRIVACY PAGE (04)
      // ══════════════════════════════════════════
      'priv_tag': '04',
      'priv_category': 'PRIVACY FIRST',
      'priv_title': '100% On-Device.\nYour Data\nNever Leaves.',
      'priv_subtitle':
          'Medical conversations, legal discussions, personal moments — sign language captures some of the most private communications. Vani processes everything on your device. Zero cloud. Zero logs. Zero compromise.',

      'priv_stat1_val': '0 bytes',
      'priv_stat1_label': 'Data Sent to Servers',
      'priv_stat1_desc': 'All inference runs locally',
      'priv_stat2_val': '0ms',
      'priv_stat2_label': 'Network Latency',
      'priv_stat2_desc': 'No cloud round-trip required',
      'priv_stat3_val': '100%',
      'priv_stat3_label': 'On-Device Processing',
      'priv_stat3_desc': 'Camera frames never transmitted',
      'priv_stat4_val': 'PDPB',
      'priv_stat4_label': 'India Data Protection',
      'priv_stat4_desc': 'Compliant with DPDP 2023 Act by design',

      'priv_s1_title': 'Why Privacy Matters More for DHH',
      'priv_s1_c1_title': 'Medical Privacy is Non-Negotiable',
      'priv_s1_c1_body':
          'When a DHH patient signs to a doctor about symptoms, diagnoses, or mental health — that conversation is deeply private. Cloud-based translation would transmit these video frames to remote servers, creating permanent records of sensitive health disclosures without explicit consent.',
      'priv_s1_c2_title': 'Legal & Financial Conversations',
      'priv_s1_c2_body':
          'DHH individuals regularly need assistance during banking, legal consultations, and property transactions. With Vani\'s on-device model, what is signed during a bank visit or lawyer meeting stays exclusively on the user\'s device — no third party can ever access those frames.',
      'priv_s1_c3_title': 'Surveillance Risk for Marginalized Communities',
      'priv_s1_c3_body':
          'India\'s DHH community already faces cultural stigma and systemic neglect. Cloud video uploads create an additional vulnerability — corporate data harvesting and unauthorized data use. On-device processing eliminates this risk entirely.',

      'priv_s2_title': 'Vani\'s Privacy Architecture',
      'priv_s2_c1_title': 'Edge Inference — TFLite / ONNX Runtime',
      'priv_s2_c1_body':
          'Vani\'s sign language model runs as a TensorFlow Lite or ONNX file on-device. Camera frames are processed in memory, passed through the model, and discarded — never written to disk or transmitted. The model is static, distributed once, updated only via app updates.',
      'priv_s2_c2_title': 'No Account. No Login. No Tracking.',
      'priv_s2_c2_body':
          'Vani requires zero user registration. There are no analytics SDKs, no crash reporters that upload PII, and no ad networks. The only data stored is the translated text — on the user\'s device, deletable at any time.',
      'priv_s2_c3_title': 'DPDP Act 2023 — Designed for Compliance',
      'priv_s2_c3_body':
          'India\'s Digital Personal Data Protection Act 2023 establishes rights around data minimization and purpose limitation. Vani collects no personal data, making it trivially compliant — not by retrofitting privacy, but by architectural choice.',
      'priv_quote':
          'Privacy is not about having something to hide. It is about having something to protect — your body language, your vulnerabilities, your conversations, your humanity.',
      'priv_quote_src': 'VANI DESIGN PHILOSOPHY — PRIVACY BY ARCHITECTURE',

      'priv_s3_title': 'Privacy Comparison',
      'priv_bar1': 'Vani — Data sent to cloud',
      'priv_bar2': 'Competitor A (cloud ASL) — Data transmitted',
      'priv_bar3': 'Competitor B (hybrid) — Data partially sent',
      'priv_bar4': 'Traditional interpreter — Privacy risk',
      'priv_bar5': 'Vani — Inference latency vs cloud round-trip',

      'priv_s4_title': 'Technical Privacy Guarantees',
      'priv_t1_year': 'Step 1',
      'priv_t1_event':
          'Camera opens — frames processed in RAM only. No file system writes at any point.',
      'priv_t2_year': 'Step 2',
      'priv_t2_event':
          'Frame passed to on-device model — GPU/NPU accelerated inference, no network calls.',
      'priv_t3_year': 'Step 3',
      'priv_t3_event':
          'Prediction returned as text string — original frame immediately dereferenced and garbage collected.',
      'priv_t4_year': 'Step 4',
      'priv_t4_event':
          'Text displayed on screen — stored only in local app memory, never synced.',
      'priv_t5_year': 'Step 5',
      'priv_t5_event':
          'User taps Delete — text is wiped. No backup, no cloud sync, no recovery possible.',

      // ══════════════════════════════════════════
      //  OFFLINE PAGE (05)
      // ══════════════════════════════════════════
      'off_tag': '05',
      'off_category': 'OFFLINE READY',
      'off_title': 'Works Anywhere.\nNo Internet.\nNo Compromise.',
      'off_subtitle':
          'India\'s DHH population is concentrated in rural areas with poor or no connectivity. A tool that requires internet is a tool that excludes the most vulnerable. Vani works at 0 kbps — always.',

      'off_stat1_val': '65%',
      'off_stat1_label': 'Rural India Connectivity',
      'off_stat1_desc': 'Limited or no 4G in remote districts',
      'off_stat2_val': '~25MB',
      'off_stat2_label': 'Model Size',
      'off_stat2_desc': 'Compressed ISL model on-device',
      'off_stat3_val': '<50ms',
      'off_stat3_label': 'Inference Time',
      'off_stat3_desc': 'Per frame on mid-tier Android',
      'off_stat4_val': '8M+',
      'off_stat4_label': 'Potential Rural Users',
      'off_stat4_desc': 'DHH individuals in underserved areas',

      'off_s1_title': 'The Rural Connectivity Problem',
      'off_s1_c1_title': 'India\'s Digital Divide is Real',
      'off_s1_c1_body':
          'According to TRAI and NSSO data, over 65% of rural India experiences inconsistent 4G connectivity. In states like Jharkhand, Chhattisgarh, and rural Odisha — where DHH populations are significant and underserved — internet access drops to 2G or nil in many districts.',
      'off_s1_c2_title': 'Emergency Situations Cannot Wait for a Signal',
      'off_s1_c2_body':
          'When a DHH person needs to communicate with emergency services, a doctor, or a police officer — they cannot wait for a 4G signal. Offline operation means Vani functions in hospitals with signal-blocked wards, rural clinics, and remote villages equally.',
      'off_s1_c3_title': 'Schools in Low-Connectivity Zones',
      'off_s1_c3_body':
          'India has 387 deaf schools, many in tier-2, tier-3 cities, or rural areas. Offline capability means Vani can be used as a classroom learning aid, a teacher-student communication tool, and a homework helper without any dependence on school WiFi or mobile data.',

      'off_s2_title': 'Connectivity Access vs DHH Population',
      'off_bar1': 'Metro cities — Connectivity',
      'off_bar2': 'Tier-2 cities — Connectivity',
      'off_bar3': 'Tier-3 cities — Connectivity',
      'off_bar4': 'Rural areas — Connectivity',
      'off_bar5': 'Remote villages — Connectivity',
      'off_bar6': 'DHH population in rural India',

      'off_s3_title': 'How Offline Works in Vani',
      'off_s3_c1_title': 'Model Bundled at Install — No Download Required',
      'off_s3_c1_body':
          'The ISL recognition model (~25MB compressed) ships inside the app package. On first launch, it is extracted to internal storage. From that point, camera → inference → text works entirely offline. No update required to use the core translation function.',
      'off_s3_c2_title': 'Battery-Optimised Inference',
      'off_s3_c2_body':
          'Vani uses frame-skipping logic — analysing every 3rd–5th camera frame rather than every frame. This reduces model inference calls by 60–80% while maintaining translation accuracy, significantly extending battery life for prolonged sessions in field conditions.',
      'off_s3_c3_title': 'Works on Android 6.0+ & iOS 13+',
      'off_s3_c3_body':
          'Device coverage is maximised by targeting APIs available on 5-year-old hardware. A DHH user with a ₹6,000 used Android phone bought in 2019 can run Vani at full functionality — no 5G chip, no Neural Engine, no flagship specs required.',
      'off_quote':
          'Technology that only works when everything is perfect is not technology for the real world. The most vulnerable users always live furthest from perfect.',
      'off_quote_src': 'VANI ENGINEERING PRINCIPLES — RESILIENCE BY DESIGN',

      'off_s4_title': 'Offline Capability Roadmap',
      'off_t1_year': 'v1.0',
      'off_t1_event':
          'Core ISL alphabet & common words — Full offline inference, 16,000 sample trained model',
      'off_t2_year': 'v1.5',
      'off_t2_event':
          'Sentence-level recognition — Contextual prediction for longer sign sequences, offline',
      'off_t3_year': 'v2.0',
      'off_t3_event':
          'Regional dialect support — Offline models for distinct ISL variants used in different states',
      'off_t4_year': 'v2.5',
      'off_t4_event':
          'Two-way offline translation — Text-to-sign animation fully on-device, no connection needed',

      // ══════════════════════════════════════════
      //  EDUCATION PAGE (06)
      // ══════════════════════════════════════════
      'edu_tag': '06',
      'edu_category': 'EDUCATION',
      'edu_title': 'Learn ISL\nThrough Real-Time\nAI Feedback',
      'edu_subtitle':
          'With fewer than 1% of deaf children reaching college, India\'s DHH education crisis demands a new model. Vani turns every phone into an ISL learning tool — with instant feedback, no teacher required.',

      'edu_stat1_val': '<1%',
      'edu_stat1_label': 'DHH Reaching College',
      'edu_stat1_desc': 'In entire India',
      'edu_stat2_val': '5%',
      'edu_stat2_label': 'DHH Children in School',
      'edu_stat2_desc': 'Of any type — a catastrophic gap',
      'edu_stat3_val': '387',
      'edu_stat3_label': 'Deaf Schools in India',
      'edu_stat3_desc': 'For 63 million — critically insufficient',
      'edu_stat4_val': '16K',
      'edu_stat4_label': 'Training Samples',
      'edu_stat4_desc': 'Vani model trained dataset size',

      'edu_s1_title': 'India\'s DHH Education Crisis',
      'edu_s1_c1_title': 'Only 5% of Deaf Children Are in School',
      'edu_s1_c1_body':
          'Only 5% of deaf children in India are enrolled in any form of school. With 19%+ out-of-school as per a 2014 government survey, and a near-total absence in higher education — the compounding disadvantage over a lifetime is severe.',
      'edu_s1_c2_title': 'The Oralism Trap',
      'edu_s1_c2_body':
          'India\'s deaf schools predominantly use oralism — teaching children to speak and lip-read rather than sign. This denies deaf children their natural language (ISL), slows learning, and results in lower literacy rates compared to bilingual education models validated globally.',
      'edu_s1_c3_title': 'Teacher Shortage is Acute',
      'edu_s1_c3_body':
          'India does not have enough ISL-trained teachers for its 387 deaf schools, let alone for the inclusion in mainstream schools mandated by RPwD 2016. ISLRTC was established in 2015 to address this, but the training pipeline is decades behind the need.',

      'edu_s2_title': 'Education Outcome Data',
      'edu_bar1': 'DHH below secondary education level',
      'edu_bar2': 'DHH with speech disability below secondary',
      'edu_bar3': 'Rural DHH children receiving no education',
      'edu_bar4': 'DHH reaching higher secondary',
      'edu_bar5': 'DHH reaching college or above',

      'edu_s3_title': 'Vani as an Educational Tool',
      'edu_s3_c1_title': 'Real-Time Sign Feedback for Learners',
      'edu_s3_c1_body':
          'A hearing student learning ISL can sign in front of Vani\'s camera and instantly see whether their gesture was recognised correctly. This closed-loop feedback replaces the need for a constant teacher — making self-paced ISL learning possible for the first time.',
      'edu_s3_c2_title': 'Classroom Communication Aid',
      'edu_s3_c2_body':
          'A DHH student in a mainstream school can use Vani to express complex thoughts to a hearing teacher without writing. A hearing teacher can use Vani to confirm whether they understood a student\'s signs — democratising inclusion without full interpreter presence.',
      'edu_s3_c3_title': 'Vocabulary Builder via Repetition Recognition',
      'edu_s3_c3_body':
          'Vani logs which signs were correctly recognised in a session (locally, never uploaded). Users can review their accuracy on specific signs — effectively practicing ISL vocabulary with AI-scored feedback, proven to accelerate retention.',
      'edu_quote':
          'We cannot say with confidence that even 10% of deaf children are in schools of any type. We cannot say 5% get a high school education. The number in college could be below a quarter of one percent.',
      'edu_quote_src': 'REHABILITATION COUNCIL OF INDIA — DISABILITY IDENTITY REPORT',

      'edu_s4_title': 'Policy & Educational Milestones',
      'edu_t1_year': '1964',
      'edu_t1_event':
          'Kothari Commission — Shifted disability education from "humanitarian to utilitarian" framing',
      'edu_t2_year': '2001',
      'edu_t2_event':
          'First formal ISL classes in India — No structured ISL teaching existed before this year',
      'edu_t3_year': '2009',
      'edu_t3_event':
          'RTE Act — Right to free and compulsory education for every disabled child mandated',
      'edu_t4_year': '2015',
      'edu_t4_event':
          'ISLRTC established — 5-year plan to train ISL teachers and develop curriculum materials',
      'edu_t5_year': '2020',
      'edu_t5_event':
          'NEP 2020 — Recommends ISL teaching nationwide; recognises DHH children\'s right to sign-based education',
      'edu_t6_year': '2026',
      'edu_t6_event':
          'Vani v1.0 — First accessible AI-powered ISL learning feedback tool available to every Indian smartphone user',
    },

    // ═══════════════════════════════════════════════════
    //  HINDI
    // ═══════════════════════════════════════════════════
    'hi': {
      // ── Navbar
      'nav_home': 'मुख्य',
      'nav_terminal': 'टर्मिनल',
      'nav_api': 'एपीआई',
      'nav_language': 'भाषा',
      'nav_signs': 'संकेत',

      // ── Badge
      'badge': 'वाणी विज़न — 16k डेटासेट प्रशिक्षित',

      // ── Hero
      'hero_title_1': 'सांकेतिक ',
      'hero_title_highlight': 'भाषा ',
      'hero_title_2': 'को टेक्स्ट में\nबदलें, तुरंत।',
      'hero_sub':
          'ऑन-डिवाइस AI द्वारा भारत के बधिर समुदाय को सशक्त बनाना।\nसटीकता के लिए निर्मित। गरिमा के लिए डिज़ाइन।',
      'get_started': 'टर्मिनल खोलें',

      // ── Stats
      'stat_mute_label': 'भारत में बधिर व मूक',
      'stat_isl_label': 'ISL उपयोगकर्ता',
      'stat_translators_label': 'प्रमाणित दुभाषिए',

      // ── Objectives grid
      'obj_heading': 'हम किसके लिए खड़े हैं',
      'obj_sub': 'उद्देश्य के साथ निर्मित। प्रभाव के लिए डिज़ाइन।',
      'obj_accessibility': 'पहुंच',
      'obj_accessibility_desc': 'सभी के लिए संचार बाधाओं को तोड़ना',
      'obj_bridging': 'खाई पाटना',
      'obj_bridging_desc': 'बधिर और श्रवण समुदायों को जोड़ना',
      'obj_inclusivity': 'समावेशिता',
      'obj_inclusivity_desc': 'एक डिजिटल दुनिया जो हर भाषा बोले',
      'obj_privacy': 'गोपनीयता प्रथम',
      'obj_privacy_desc': '100% ऑन-डिवाइस — आपका डेटा कभी नहीं जाता',
      'obj_offline': 'ऑफलाइन तैयार',
      'obj_offline_desc': 'इंटरनेट के बिना भी काम करता है',
      'obj_education': 'शिक्षा',
      'obj_education_desc': 'रियल-टाइम AI फीडबैक से ISL सीखें',

      // ── Vision
      'vision_title': 'वाणी AI से मौन को शक्ति',
      'vision_body':
          'भारत में हर 33,000+ बधिर व मूक व्यक्तियों के लिए केवल 1 प्रमाणित दुभाषिया है। वाणी इस अंतर को पाटता है — सीधे आपके डिवाइस पर रियल-टाइम अनुवाद प्रदान करता है।',

      // ── Translate Screen
      'translate_vision_title': 'AI विज़न स्ट्रीम',
      'translate_vision_sub': 'रियल-टाइम सांकेतिक भाषा डेटा प्रोसेस हो रहा है',
      'translate_prediction': 'रियल-टाइम पूर्वानुमान',
      'translate_waiting': 'प्रतीक्षा में...',
      'translate_transcription': 'ट्रांसक्रिप्शन',
      'translate_hint': 'पहचाने गए संकेत यहाँ दिखेंगे...',
      'translate_start': 'कैप्चर शुरू करें',
      'translate_switch': 'बदलें',
      'translate_cam_on': 'चालू',
      'translate_cam_off': 'बंद',

      // ── Dialog
      'dialog_title': 'वाणी कोर तैयार',
      'dialog_body':
          'कैमरा टॉगल करके AI मॉड्यूल शुरू करें। सटीक अनुवाद के लिए अपने हाथ फ्रेम में रखें।',
      'dialog_btn': 'मॉड्यूल इनिशियलाइज़ करें',

      // ── Language names
      'lang_en': 'English',
      'lang_hi': 'हिन्दी',
      'lang_mr': 'मराठी',

      // ── Shared UI
      'obj_page_back': 'होम पर वापस',
      'obj_page_explore': 'जानें →',
      'obj_page_confidence': 'विश्वास',
      'obj_crisis_stat': '1 दुभाषिया : 33,000+ लोग',
      'obj_quote_icon_label': 'उद्धरण',

      // ══════════════════════════════════════════
      //  SIGNS PAGE (HINDI)
      // ══════════════════════════════════════════
      'signs_title_1': 'ISL ',
      'signs_title_highlight': 'संकेत पुस्तकालय',
      'signs_subtitle':
          'वाणी द्वारा समर्थित सभी 64 भारतीय सांकेतिक भाषा संकेत देखें। हस्त आकार, अर्थ और उपयोग विवरण देखने के लिए किसी भी कार्ड पर टैप करें।',

      'signs_stat_total':    'कुल संकेत',
      'signs_stat_alphabet': 'वर्णमाला',
      'signs_stat_numbers':  'संख्याएं',
      'signs_stat_words':    'शब्द',

      'signs_search_hint': 'नाम, अर्थ या श्रेणी से खोजें…',
      'cat_all':            'सभी',
      'cat_alphabet':       'वर्णमाला',
      'cat_numbers':        'संख्याएं',
      'cat_words':          'शब्द',

      'signs_showing_all':      'सभी {n} संकेत दिखाए जा रहे हैं',
      'signs_showing_filtered': '{total} में से {n} संकेत दिखाए जा रहे हैं',

      'signs_no_results':     'कोई संकेत नहीं मिला',
      'signs_no_results_sub': 'खोज या फ़िल्टर बदलकर प्रयास करें',

      // Alphabet (Hindi)
      'sign_a_name': 'अक्षर A', 'sign_a_meaning': 'अक्षर A', 'sign_a_desc': 'बंद मुट्ठी, अंगूठा तर्जनी के पास।',
      'sign_b_name': 'अक्षर B', 'sign_b_meaning': 'अक्षर B', 'sign_b_desc': 'चारों उंगलियां सीधी ऊपर, अंगूठा हथेली पर मुड़ा।',
      'sign_c_name': 'अक्षर C', 'sign_c_meaning': 'अक्षर C', 'sign_c_desc': 'हाथ C आकार में मुड़ा, उंगलियां और अंगूठा आमने-सामने।',
      'sign_d_name': 'अक्षर D', 'sign_d_meaning': 'अक्षर D', 'sign_d_desc': 'तर्जनी ऊपर, बाकी उंगलियां और अंगूठा वृत्त बनाते हैं।',
      'sign_e_name': 'अक्षर E', 'sign_e_meaning': 'अक्षर E', 'sign_e_desc': 'चारों उंगलियां मध्य जोड़ पर मुड़ी, अंगूठा नीचे।',
      'sign_f_name': 'अक्षर F', 'sign_f_meaning': 'अक्षर F', 'sign_f_desc': 'तर्जनी और अंगूठा वृत्त बनाते हैं, तीन उंगलियां ऊपर।',
      'sign_g_name': 'अक्षर G', 'sign_g_meaning': 'अक्षर G', 'sign_g_desc': 'तर्जनी और अंगूठा क्षैतिज समानांतर।',
      'sign_h_name': 'अक्षर H', 'sign_h_meaning': 'अक्षर H', 'sign_h_desc': 'तर्जनी और मध्यमा क्षैतिज साथ-साथ।',
      'sign_i_name': 'अक्षर I', 'sign_i_meaning': 'अक्षर I', 'sign_i_desc': 'केवल छोटी उंगली ऊपर, बाकी मुट्ठी में।',
      'sign_j_name': 'अक्षर J', 'sign_j_meaning': 'अक्षर J', 'sign_j_desc': 'छोटी उंगली से हवा में J बनाएं।',
      'sign_k_name': 'अक्षर K', 'sign_k_meaning': 'अक्षर K', 'sign_k_desc': 'तर्जनी और मध्यमा V में, अंगूठा बीच में।',
      'sign_l_name': 'अक्षर L', 'sign_l_meaning': 'अक्षर L', 'sign_l_desc': 'तर्जनी ऊपर, अंगूठा बाहर — L आकार।',
      'sign_m_name': 'अक्षर M', 'sign_m_meaning': 'अक्षर M', 'sign_m_desc': 'तीन उंगलियां अंगूठे पर मुड़ी।',
      'sign_n_name': 'अक्षर N', 'sign_n_meaning': 'अक्षर N', 'sign_n_desc': 'तर्जनी और मध्यमा अंगूठे पर मुड़ी।',
      'sign_o_name': 'अक्षर O', 'sign_o_meaning': 'अक्षर O', 'sign_o_desc': 'सभी उंगलियां और अंगूठा मिलकर O बनाते हैं।',
      'sign_p_name': 'अक्षर P', 'sign_p_meaning': 'अक्षर P', 'sign_p_desc': 'तर्जनी और मध्यमा नीचे, अंगूठा बाहर।',
      'sign_q_name': 'अक्षर Q', 'sign_q_meaning': 'अक्षर Q', 'sign_q_desc': 'तर्जनी और अंगूठा नीचे Q बनाते हैं।',
      'sign_r_name': 'अक्षर R', 'sign_r_meaning': 'अक्षर R', 'sign_r_desc': 'तर्जनी और मध्यमा एक-दूसरे पर क्रॉस।',
      'sign_s_name': 'अक्षर S', 'sign_s_meaning': 'अक्षर S', 'sign_s_desc': 'बंद मुट्ठी, अंगूठा उंगलियों के सामने।',
      'sign_t_name': 'अक्षर T', 'sign_t_meaning': 'अक्षर T', 'sign_t_desc': 'अंगूठा तर्जनी और मध्यमा के बीच।',
      'sign_u_name': 'अक्षर U', 'sign_u_meaning': 'अक्षर U', 'sign_u_desc': 'तर्जनी और मध्यमा साथ ऊपर।',
      'sign_v_name': 'अक्षर V', 'sign_v_meaning': 'अक्षर V', 'sign_v_desc': 'तर्जनी और मध्यमा V में, हथेली बाहर।',
      'sign_w_name': 'अक्षर W', 'sign_w_meaning': 'अक्षर W', 'sign_w_desc': 'तीन उंगलियां W बनाती हैं।',
      'sign_x_name': 'अक्षर X', 'sign_x_meaning': 'अक्षर X', 'sign_x_desc': 'तर्जनी हुक आकार में।',
      'sign_y_name': 'अक्षर Y', 'sign_y_meaning': 'अक्षर Y', 'sign_y_desc': 'अंगूठा और छोटी उंगली बाहर।',
      'sign_z_name': 'अक्षर Z', 'sign_z_meaning': 'अक्षर Z', 'sign_z_desc': 'तर्जनी से हवा में Z बनाएं।',

      // Numbers (Hindi)
      'sign_0_name': 'संख्या 0', 'sign_0_meaning': 'शून्य', 'sign_0_desc': 'सभी उंगलियां मिलकर O बनाती हैं।',
      'sign_1_name': 'संख्या 1', 'sign_1_meaning': 'एक', 'sign_1_desc': 'केवल तर्जनी ऊपर।',
      'sign_2_name': 'संख्या 2', 'sign_2_meaning': 'दो', 'sign_2_desc': 'तर्जनी और मध्यमा V में।',
      'sign_3_name': 'संख्या 3', 'sign_3_meaning': 'तीन', 'sign_3_desc': 'तीन उंगलियां ऊपर।',
      'sign_4_name': 'संख्या 4', 'sign_4_meaning': 'चार', 'sign_4_desc': 'चार उंगलियां फैलाकर ऊपर।',
      'sign_5_name': 'संख्या 5', 'sign_5_meaning': 'पांच', 'sign_5_desc': 'सभी पांच उंगलियां फैली।',
      'sign_6_name': 'संख्या 6', 'sign_6_meaning': 'छह', 'sign_6_desc': 'छोटी उंगली और अंगूठा मिले, तीन ऊपर।',
      'sign_7_name': 'संख्या 7', 'sign_7_meaning': 'सात', 'sign_7_desc': 'अनामिका और अंगूठा मिले, बाकी ऊपर।',
      'sign_8_name': 'संख्या 8', 'sign_8_meaning': 'आठ', 'sign_8_desc': 'मध्यमा और अंगूठा मिले, बाकी ऊपर।',
      'sign_9_name': 'संख्या 9', 'sign_9_meaning': 'नौ', 'sign_9_desc': 'तर्जनी और अंगूठा वृत्त, बाकी ऊपर।',

      // Words (Hindi)
      'sign_namaste_name': 'नमस्ते', 'sign_namaste_meaning': 'अभिवादन / सम्मान', 'sign_namaste_desc': 'दोनों हथेलियां छाती पर जोड़ी, उंगलियां ऊपर।',
      'sign_hello_name': 'हैलो', 'sign_hello_meaning': 'हैलो / अभिवादन', 'sign_hello_desc': 'खुली हथेली माथे तक उठाई, फिर बाहर।',
      'sign_hi_name': 'हाय', 'sign_hi_meaning': 'हाय / आकस्मिक अभिवादन', 'sign_hi_desc': 'खुला हाथ कंधे की ऊंचाई पर हिलाएं।',
      'sign_howareyou_name': 'आप कैसे हैं?', 'sign_howareyou_meaning': 'आप कैसे हैं?', 'sign_howareyou_desc': 'मुड़ा हाथ छाती से बाहर, फिर तर्जनी सामने।',
      'sign_quiet_name': 'शांत / चुप', 'sign_quiet_meaning': 'शांत / मौन', 'sign_quiet_desc': 'तर्जनी बंद होठों पर रखें।',
      'sign_thanks_name': 'धन्यवाद', 'sign_thanks_meaning': 'धन्यवाद / आभार', 'sign_thanks_desc': 'सपाट हाथ ठुड्डी से सामने की ओर।',
      'sign_food_name': 'खाना', 'sign_food_meaning': 'खाना / खाना खाना', 'sign_food_desc': 'सभी उंगलियां मुंह की ओर बार-बार।',
      'sign_iloveyou_name': 'आई लव यू', 'sign_iloveyou_meaning': 'मैं तुमसे प्यार करता/करती हूं', 'sign_iloveyou_desc': 'तर्जनी, छोटी उंगली और अंगूठा बाहर।',
      'sign_brother_name': 'भाई', 'sign_brother_meaning': 'भाई', 'sign_brother_desc': 'L हस्त आकार माथे पर, फिर नीचे।',
      'sign_father_name': 'पिता / पापा', 'sign_father_meaning': 'पिता', 'sign_father_desc': 'खुला हाथ अंगूठा माथे पर।',
      'sign_mother_name': 'माता / मम्मी', 'sign_mother_meaning': 'माता', 'sign_mother_desc': 'खुला हाथ अंगूठा ठुड्डी पर।',
      'sign_water_name': 'पानी', 'sign_water_meaning': 'पानी', 'sign_water_desc': 'W हस्त आकार ठुड्डी पर दो बार।',
      'sign_what_name': 'क्या?', 'sign_what_meaning': 'क्या? / प्रश्न', 'sign_what_desc': 'तर्जनी आगे-पीछे हिलाएं।',
      'sign_please_name': 'कृपया', 'sign_please_meaning': 'कृपया / अनुरोध', 'sign_please_desc': 'छाती पर गोल घुमाव।',
      'sign_help_name': 'मदद / SOS', 'sign_help_meaning': 'मदद / आपातकाल', 'sign_help_desc': 'सपाट हाथ मुट्ठी के नीचे, दोनों ऊपर।',
      'sign_loud_name': 'तेज / शोर', 'sign_loud_meaning': 'तेज / शोर', 'sign_loud_desc': 'तर्जनियां कानों पर, फिर हाथ बाहर।',
      'sign_yours_name': 'आपका / आप', 'sign_yours_meaning': 'आपका / आप', 'sign_yours_desc': 'तर्जनी सामने वाले की ओर।',
      'sign_sleeping_name': 'सोना', 'sign_sleeping_meaning': 'नींद / सोना', 'sign_sleeping_desc': 'खुला हाथ चेहरे के सामने नीचे।',
      'sign_name_name': 'नाम', 'sign_name_meaning': 'नाम / आपका नाम क्या है?', 'sign_name_desc': 'H हस्त आकार दूसरे H पर दो बार।',
      'sign_sorry_name': 'माफ़ करें', 'sign_sorry_meaning': 'माफ़ी / क्षमा', 'sign_sorry_desc': 'बंद मुट्ठी छाती पर गोल घुमाव।',
      'sign_good_name': 'अच्छा', 'sign_good_meaning': 'अच्छा / शाबाश', 'sign_good_desc': 'सपाट हाथ होठों से आगे।',
      'sign_bad_name': 'बुरा', 'sign_bad_meaning': 'बुरा / गलत', 'sign_bad_desc': 'सपाट हाथ होठों से नीचे की ओर।',
      'sign_today_name': 'आज', 'sign_today_meaning': 'आज / अभी', 'sign_today_desc': 'Y हस्त आकार कमर से नीचे।',
      'sign_time_name': 'समय', 'sign_time_meaning': 'समय / घड़ी', 'sign_time_desc': 'तर्जनी कलाई पर दो बार।',
      'sign_strong_name': 'मजबूत', 'sign_strong_meaning': 'मजबूत / शक्तिशाली', 'sign_strong_desc': 'C हस्त आकार कंधे से मुट्ठी में।',
      'sign_love_name': 'प्यार', 'sign_love_meaning': 'प्यार / स्नेह', 'sign_love_desc': 'दोनों बाहें छाती पर क्रॉस।',
      'sign_bandaid_name': 'डॉक्टर / चिकित्सा', 'sign_bandaid_meaning': 'डॉक्टर / चिकित्सा सहायता', 'sign_bandaid_desc': 'M हस्त आकार कलाई के अंदर।',
      'sign_happy_name': 'खुश', 'sign_happy_meaning': 'खुश / प्रसन्न', 'sign_happy_desc': 'छाती पर गोल ऊपर की ओर।',

      // ── ACCESSIBILITY (Hindi)
      'acc_tag': '01',
      'acc_category': 'पहुंच',
      'acc_title': 'संचार\nबाधाओं को\nतोड़ना',
      'acc_subtitle':
          '6 करोड़ से अधिक बधिर भारतीयों के लिए हर बातचीत एक ऐसे पुल की मांग करती है जो शायद ही कभी मौजूद हो। वाणी वह पुल है — तत्काल, निजी और ऑन-डिवाइस।',
      'acc_stat1_val': '6.3 करोड़+', 'acc_stat1_label': 'भारत में बधिर', 'acc_stat1_desc': 'दुनिया की सबसे बड़ी ऐसी आबादी',
      'acc_stat2_val': '5%', 'acc_stat2_label': 'स्कूल में बच्चे', 'acc_stat2_desc': 'किसी भी प्रकार की शिक्षा में नामांकित',
      'acc_stat3_val': '26%', 'acc_stat3_label': 'रोजगार दर', 'acc_stat3_desc': 'सक्रिय रोजगार में DHH वयस्क',
      'acc_stat4_val': '387', 'acc_stat4_label': 'बधिर विद्यालय', 'acc_stat4_desc': '6 करोड़ की आबादी के लिए',
      'acc_s1_title': 'पहुंच का संकट',
      'acc_s1_c1_title': 'संचार एक मानव अधिकार है — जो प्रतिदिन अस्वीकार किया जाता है',
      'acc_s1_c1_body': 'भारत का बधिर समुदाय शिक्षा, स्वास्थ्य, रोजगार और नागरिक जीवन से व्यवस्थित रूप से बाहर है। हर 33,000+ उपयोगकर्ताओं के लिए केवल 1 प्रमाणित दुभाषिया है।',
      'acc_s1_c2_title': 'शहरी–ग्रामीण विभाजन',
      'acc_s1_c2_body': 'भारत के अधिकांश 387 बधिर स्कूल शहरी केंद्रों में हैं। ग्रामीण बधिर बच्चों को स्कूल तक पहुंचने के लिए घंटों सफर करना पड़ता है।',
      'acc_s1_c3_title': 'बिना शब्दों के स्वास्थ्य सेवा',
      'acc_s1_c3_body': 'साइन भाषा सहायता के बिना चिकित्सीय परामर्श गलत निदान और देरी से उपचार की ओर ले जाता है।',
      'acc_s2_title': 'वाणी जिन बाधाओं को लक्षित करता है',
      'acc_bar1': 'सार्वजनिक परिवहन और नेविगेशन', 'acc_bar2': 'स्वास्थ्य संचार',
      'acc_bar3': 'कार्यस्थल पर बातचीत', 'acc_bar4': 'सरकारी सेवाओं तक पहुंच',
      'acc_bar5': 'शैक्षणिक भागीदारी', 'acc_bar6': 'आपातकालीन सेवाएं',
      'acc_s3_title': 'वाणी बाधाएं कैसे तोड़ता है',
      'acc_s3_c1_title': 'ऑन-डिवाइस, शून्य विलंबता अनुवाद',
      'acc_s3_c1_body': 'वाणी एक प्रशिक्षित मॉडल का उपयोग करके पूरी तरह ऑन-डिवाइस साइन भाषा फ्रेम प्रोसेस करता है।',
      'acc_s3_c2_title': 'कोई दुभाषिया नहीं चाहिए',
      'acc_s3_c2_body': 'पेशेवर दुभाषियों की लागत ₹800–₹2,500/घंटा है। वाणी किसी भी Android/iOS डिवाइस पर ₹0 टूल।',
      'acc_quote': 'विकलांगता व्यक्ति में नहीं है — यह पर्यावरण में है। जब हम पर्यावरण से बाधाएं हटाते हैं, तो विकलांगता गायब हो जाती है।',
      'acc_quote_src': 'विकलांगता का सामाजिक मॉडल — विकलांग व्यक्तियों के अधिकारों पर UN कन्वेंशन',
      'acc_s4_title': 'भारत में कानूनी ढांचा',
      'acc_t1_year': '1992', 'acc_t1_event': 'भारतीय पुनर्वास परिषद अधिनियम — विकलांगता पुनर्वास के लिए पहला वैधानिक निकाय',
      'acc_t2_year': '1995', 'acc_t2_event': 'विकलांग व्यक्ति अधिनियम — समान अवसर और समावेशी शिक्षा का आदेश',
      'acc_t3_year': '2015', 'acc_t3_event': 'ISLRTC की स्थापना — भारतीय सांकेतिक भाषा अनुसंधान एवं प्रशिक्षण केंद्र बना',
      'acc_t4_year': '2016', 'acc_t4_event': 'RPwD अधिनियम 2016 — विस्तारित विकलांगता परिभाषाएं, 21 श्रेणियां',
      'acc_t5_year': '2020', 'acc_t5_event': 'NEP 2020 — राष्ट्रीय शिक्षा नीति ने सभी स्कूलों में ISL शिक्षण की सिफारिश की',

      // ── BRIDGING GAPS (Hindi)
      'bridge_tag': '02', 'bridge_category': 'खाई पाटना',
      'bridge_title': 'बधिर और\nश्रवण समुदायों\nको जोड़ना',
      'bridge_subtitle': 'भारत के बधिर और श्रवण समुदायों के बीच की खाई भाषा की नहीं है — यह बुनियादी ढांचे की है।',
      'bridge_stat1_val': '1.8 करोड़', 'bridge_stat1_label': 'वास्तविक DHH आबादी', 'bridge_stat1_desc': 'NAD भारत के अनुसार',
      'bridge_stat2_val': '73.9%', 'bridge_stat2_label': 'सीमांत कामगार', 'bridge_stat2_desc': '15–59 वर्ष के DHH भारतीय',
      'bridge_stat3_val': '1:33K', 'bridge_stat3_label': 'दुभाषिया अनुपात', 'bridge_stat3_desc': 'प्रति 33,000 उपयोगकर्ताओं पर 1 दुभाषिया',
      'bridge_stat4_val': '300', 'bridge_stat4_label': 'बधिर विद्यालय', 'bridge_stat4_desc': 'ISL पाठ्यक्रम के साथ',
      'bridge_s1_title': 'खाई क्यों है',
      'bridge_s1_c1_title': 'ISL अभी भी आधिकारिक भाषा नहीं',
      'bridge_s1_c1_body': 'भारतीय सांकेतिक भाषा 80 लाख से अधिक लोगों द्वारा उपयोग की जाती है लेकिन इसे संवैधानिक मान्यता नहीं है।',
      'bridge_s1_c2_title': 'स्कूलों में मौखिकवाद बनाम साइन भाषा',
      'bridge_s1_c2_body': 'अधिकांश भारतीय बधिर स्कूल "मौखिकवाद" का उपयोग करते हैं — बच्चों को होंठ पढ़ना और बोलना सिखाते हैं।',
      'bridge_s1_c3_title': 'चुप्पी का कलंक',
      'bridge_s1_c3_body': 'शोध से पता चला है कि महाराष्ट्र, UP और तमिलनाडु के परिवार बधिरपन से "शर्मिंदा" थे।',
      'bridge_s2_title': 'सामुदायिक एकीकरण डेटा',
      'bridge_bar1': 'ISL अनुवाद तक पहुंच वाले DHH', 'bridge_bar2': 'स्मार्टफोन उपयोग करने वाले DHH',
      'bridge_bar3': 'साइन भाषा जानने वाले श्रवण लोग', 'bridge_bar4': 'औपचारिक रोजगार में DHH',
      'bridge_bar5': 'माध्यमिक+ शिक्षा वाले DHH',
      'bridge_s3_title': 'एक ब्रिज प्रोटोकॉल के रूप में वाणी',
      'bridge_s3_c1_title': 'दो-तरफा संचार परत',
      'bridge_s3_c1_body': 'वाणी एक साझा संचार इंटरफेस बनाता है। DHH व्यक्ति साइन करता है; श्रवण व्यक्ति पढ़ता है।',
      'bridge_s3_c2_title': 'रोजगार पुल',
      'bridge_s3_c2_body': 'वाणी के साथ, नौकरी के इंटरव्यू, कार्यस्थल की बैठकें और ग्राहक संचार संभव हो जाते हैं।',
      'bridge_quote': 'असली खाई बधिर और श्रवण लोगों के बीच नहीं है — यह उन लोगों के बीच है जिनके पास संचार उपकरण हैं और जिनके पास नहीं हैं।',
      'bridge_quote_src': 'नेशनल एसोसिएशन ऑफ द डेफ, भारत',
      'bridge_s4_title': 'पुल-निर्माण समयरेखा',
      'bridge_t1_year': '2011', 'bridge_t1_event': 'IGNOU में ISLRTC की स्थापना — ISL अनुसंधान के लिए पहला संस्थागत पुल',
      'bridge_t2_year': '2017', 'bridge_t2_event': 'सरकार ने ISL को शब्दकोश में संहिताबद्ध किया — 3,000+ संकेत पहली बार दर्ज',
      'bridge_t3_year': '2018', 'bridge_t3_event': 'ISLRTC ने ISL शब्दकोश प्रकाशित किया',
      'bridge_t4_year': '2023', 'bridge_t4_event': 'कैम्ब्रिज विश्वविद्यालय ने ISL को आधिकारिक भाषा बनाने की मांग की',
      'bridge_t5_year': '2026', 'bridge_t5_event': 'वाणी AI — भारत के हर स्मार्टफोन उपयोगकर्ता के लिए रियल-टाइम ISL अनुवाद',

      // ── INCLUSIVITY (Hindi)
      'incl_tag': '03', 'incl_category': 'समावेशिता',
      'incl_title': 'एक डिजिटल\nदुनिया जो हर\nभाषा बोले',
      'incl_subtitle': 'भारत में 121 प्रमुख भाषाएं हैं। आधिकारिक रूप से मान्यता प्राप्त साइन भाषाएं शून्य हैं।',
      'incl_stat1_val': '121', 'incl_stat1_label': 'भारत में भाषाएं', 'incl_stat1_desc': 'देश भर में बोली जाती हैं',
      'incl_stat2_val': '0', 'incl_stat2_label': 'आधिकारिक साइन भाषाएं', 'incl_stat2_desc': 'ISL को संवैधानिक दर्जा नहीं',
      'incl_stat3_val': '19%+', 'incl_stat3_label': 'स्कूल से बाहर DHH बच्चे', 'incl_stat3_desc': '2014 सरकारी सर्वेक्षण',
      'incl_stat4_val': '₹23,000Cr', 'incl_stat4_label': 'सहायक उपकरण बाजार', 'incl_stat4_desc': '2030 तक अनुमानित मूल्य',
      'incl_s1_title': 'समावेशी भारत कैसा दिखता है',
      'incl_s1_c1_title': 'डिजिटल इंडिया का विरोधाभास',
      'incl_s1_c1_body': 'डिजिटल इंडिया ने 90 करोड़ लोगों को इंटरनेट से जोड़ा है। फिर भी 6 करोड़ DHH नागरिकों के लिए अधिकांश डिजिटल इंटरफेस पहुंच के बाहर हैं।',
      'incl_s1_c2_title': 'सार्वजनिक परिवहन और दैनिक नेविगेशन',
      'incl_s1_c2_body': 'मेट्रो घोषणाएं, बस स्टॉप PA सिस्टम, रेलवे प्लेटफॉर्म अपडेट — सब केवल ऑडियो पर निर्भर हैं।',
      'incl_s1_c3_title': 'टेलीविजन और मीडिया से बहिष्करण',
      'incl_s1_c3_body': 'विकसित देशों में सभी समाचार प्रसारणों पर साइन भाषा विंडो या कैप्शन अनिवार्य हैं। भारत में ऐसी कोई आवश्यकता नहीं है।',
      'incl_s2_title': 'क्षेत्र के अनुसार समावेशिता अंतराल',
      'incl_bar1': 'DHH के लिए सुलभ डिजिटल सेवाएं', 'incl_bar2': 'साइन अनुवाद के साथ TV प्रसारण',
      'incl_bar3': 'ISL सहायता वाले सरकारी कार्यालय', 'incl_bar4': 'साइन-सक्षम कर्मचारियों वाले अस्पताल',
      'incl_bar5': 'DHH समावेश नीतियों वाले कार्यस्थल', 'incl_bar6': 'ISL-प्रशिक्षित शिक्षकों वाले स्कूल',
      'incl_s3_title': 'वाणी की समावेशिता वास्तुकला',
      'incl_s3_c1_title': 'बहुभाषी आउटपुट — हिंदी, अंग्रेजी, मराठी',
      'incl_s3_c1_body': 'वाणी उस भाषा में आउटपुट देता है जो उपयोगकर्ता को चाहिए।',
      'incl_s3_c2_title': 'कम-एंड डिवाइस के लिए डिज़ाइन',
      'incl_s3_c2_body': 'वाणी एज इनफरेंस के लिए अनुकूलित है — हल्के मॉडल वेट और बैटरी-कुशल संगणना के साथ।',
      'incl_quote': 'समावेशी डिज़ाइन विकलांगों के लिए सुविधाएं जोड़ने के बारे में नहीं है। यह मानव विविधता की पूरी श्रृंखला के लिए डिज़ाइन करने के बारे में है।',
      'incl_quote_src': 'विकलांग व्यक्तियों के अधिकारों पर UN कन्वेंशन — अनुच्छेद 9',
      'incl_s4_title': 'वैश्विक समावेशिता मानदंड',
      'incl_t1_year': 'USA', 'incl_t1_event': 'ADA (1990) — सभी संघीय सेवाओं में साइन भाषा पहुंच अनिवार्य',
      'incl_t2_year': 'UK', 'incl_t2_event': 'BSL को 2022 में आधिकारिक भाषा के रूप में मान्यता',
      'incl_t3_year': 'NZ', 'incl_t3_event': 'NZSL तीन आधिकारिक भाषाओं में से एक है',
      'incl_t4_year': 'IND', 'incl_t4_event': 'RPwD अधिनियम 2016 — ISL अभी भी आधिकारिक दर्जे के बिना',
      'incl_t5_year': '2030', 'incl_t5_event': 'भारत का सहायक उपकरण बाजार ₹23,000 करोड़ तक पहुंचने का अनुमान',

      // ── PRIVACY (Hindi)
      'priv_tag': '04', 'priv_category': 'गोपनीयता प्रथम',
      'priv_title': '100% ऑन-डिवाइस।\nआपका डेटा\nकभी नहीं जाता।',
      'priv_subtitle': 'वाणी सब कुछ आपके डिवाइस पर प्रोसेस करता है। शून्य क्लाउड। शून्य लॉग।',
      'priv_stat1_val': '0 बाइट', 'priv_stat1_label': 'सर्वर पर भेजा गया डेटा', 'priv_stat1_desc': 'सभी इनफरेंस स्थानीय रूप से चलती है',
      'priv_stat2_val': '0ms', 'priv_stat2_label': 'नेटवर्क विलंबता', 'priv_stat2_desc': 'कोई क्लाउड राउंड-ट्रिप नहीं',
      'priv_stat3_val': '100%', 'priv_stat3_label': 'ऑन-डिवाइस प्रोसेसिंग', 'priv_stat3_desc': 'कैमरा फ्रेम कभी प्रसारित नहीं',
      'priv_stat4_val': 'DPDP', 'priv_stat4_label': 'भारत डेटा संरक्षण', 'priv_stat4_desc': 'DPDP अधिनियम 2023 के अनुपालन में',
      'priv_s1_title': 'DHH के लिए गोपनीयता क्यों अधिक मायने रखती है',
      'priv_s1_c1_title': 'चिकित्सीय गोपनीयता अनिवार्य है',
      'priv_s1_c1_body': 'जब एक DHH रोगी डॉक्टर को लक्षणों के बारे में साइन करता है — वह बातचीत गहरी निजी है।',
      'priv_s1_c2_title': 'कानूनी और वित्तीय बातचीत',
      'priv_s1_c2_body': 'वाणी के ऑन-डिवाइस मॉडल के साथ, जो बैंक या वकील की बैठक में साइन किया जाता है वह डिवाइस पर ही रहता है।',
      'priv_s1_c3_title': 'हाशिए पर समुदायों के लिए निगरानी जोखिम',
      'priv_s1_c3_body': 'ऑन-डिवाइस प्रोसेसिंग क्लाउड डेटा हार्वेस्टिंग का जोखिम पूरी तरह समाप्त करती है।',
      'priv_s2_title': 'वाणी की गोपनीयता वास्तुकला',
      'priv_s2_c1_title': 'एज इनफरेंस — TFLite / ONNX Runtime',
      'priv_s2_c1_body': 'वाणी का साइन भाषा मॉडल ऑन-डिवाइस TensorFlow Lite या ONNX फ़ाइल के रूप में चलता है।',
      'priv_s2_c2_title': 'कोई अकाउंट नहीं। कोई लॉगिन नहीं। कोई ट्रैकिंग नहीं।',
      'priv_s2_c2_body': 'वाणी को शून्य उपयोगकर्ता पंजीकरण की आवश्यकता है। केवल अनुवादित टेक्स्ट उपयोगकर्ता के डिवाइस पर संग्रहीत होता है।',
      'priv_s2_c3_title': 'DPDP अधिनियम 2023 — डिज़ाइन द्वारा अनुपालन',
      'priv_s2_c3_body': 'वाणी कोई व्यक्तिगत डेटा एकत्र नहीं करता।',
      'priv_quote': 'गोपनीयता छुपाने के लिए कुछ होने के बारे में नहीं है। यह कुछ की रक्षा करने के बारे में है।',
      'priv_quote_src': 'वाणी डिज़ाइन दर्शन — वास्तुकला द्वारा गोपनीयता',
      'priv_s3_title': 'गोपनीयता तुलना',
      'priv_bar1': 'वाणी — क्लाउड पर भेजा गया डेटा', 'priv_bar2': 'प्रतिस्पर्धी A — डेटा प्रेषित',
      'priv_bar3': 'प्रतिस्पर्धी B — डेटा आंशिक रूप से भेजा', 'priv_bar4': 'पारंपरिक दुभाषिया — गोपनीयता जोखिम',
      'priv_bar5': 'वाणी — इनफरेंस विलंबता तुलना',
      'priv_s4_title': 'तकनीकी गोपनीयता गारंटी',
      'priv_t1_year': 'चरण 1', 'priv_t1_event': 'कैमरा खुलता है — फ्रेम केवल RAM में प्रोसेस।',
      'priv_t2_year': 'चरण 2', 'priv_t2_event': 'फ्रेम ऑन-डिवाइस मॉडल को पास — कोई नेटवर्क कॉल नहीं।',
      'priv_t3_year': 'चरण 3', 'priv_t3_event': 'भविष्यवाणी टेक्स्ट स्ट्रिंग के रूप में वापस — मूल फ्रेम तुरंत हटाया जाता है।',
      'priv_t4_year': 'चरण 4', 'priv_t4_event': 'टेक्स्ट स्क्रीन पर दिखाया जाता है — कभी सिंक नहीं।',
      'priv_t5_year': 'चरण 5', 'priv_t5_event': 'उपयोगकर्ता Delete दबाता है — टेक्स्ट मिटाया जाता है।',

      // ── OFFLINE (Hindi)
      'off_tag': '05', 'off_category': 'ऑफलाइन तैयार',
      'off_title': 'कहीं भी काम\nकरता है।\nकोई समझौता नहीं।',
      'off_subtitle': 'वाणी 0 kbps पर काम करता है — हमेशा।',
      'off_stat1_val': '65%', 'off_stat1_label': 'ग्रामीण भारत कनेक्टिविटी', 'off_stat1_desc': 'दूरदराज के जिलों में सीमित या कोई 4G नहीं',
      'off_stat2_val': '~25MB', 'off_stat2_label': 'मॉडल आकार', 'off_stat2_desc': 'ऑन-डिवाइस संपीड़ित ISL मॉडल',
      'off_stat3_val': '<50ms', 'off_stat3_label': 'इनफरेंस समय', 'off_stat3_desc': 'मिड-टियर Android पर प्रति फ्रेम',
      'off_stat4_val': '80 लाख+', 'off_stat4_label': 'संभावित ग्रामीण उपयोगकर्ता', 'off_stat4_desc': 'कम सेवा वाले क्षेत्रों में DHH',
      'off_s1_title': 'ग्रामीण कनेक्टिविटी समस्या',
      'off_s1_c1_title': 'भारत की डिजिटल खाई वास्तविक है',
      'off_s1_c1_body': 'ग्रामीण भारत के 65% से अधिक हिस्से में असंगत 4G कनेक्टिविटी है।',
      'off_s1_c2_title': 'आपातकालीन स्थितियां सिग्नल का इंतजार नहीं कर सकतीं',
      'off_s1_c2_body': 'ऑफलाइन संचालन का मतलब है वाणी अस्पतालों और दूरदराज के गांवों में भी काम करता है।',
      'off_s1_c3_title': 'कम कनेक्टिविटी क्षेत्रों में स्कूल',
      'off_s1_c3_body': 'ऑफलाइन क्षमता का मतलब है वाणी स्कूल WiFi पर निर्भर हुए बिना उपयोग किया जा सकता है।',
      'off_s2_title': 'DHH आबादी के मुकाबले कनेक्टिविटी',
      'off_bar1': 'मेट्रो शहर — कनेक्टिविटी', 'off_bar2': 'टियर-2 शहर — कनेक्टिविटी',
      'off_bar3': 'टियर-3 शहर — कनेक्टिविटी', 'off_bar4': 'ग्रामीण क्षेत्र — कनेक्टिविटी',
      'off_bar5': 'दूरदराज के गांव — कनेक्टिविटी', 'off_bar6': 'ग्रामीण भारत में DHH आबादी',
      'off_s3_title': 'वाणी में ऑफलाइन कैसे काम करता है',
      'off_s3_c1_title': 'इंस्टॉल पर बंडल मॉडल — कोई डाउनलोड आवश्यक नहीं',
      'off_s3_c1_body': 'ISL रिकग्निशन मॉडल (~25MB) ऐप पैकेज के अंदर आता है।',
      'off_s3_c2_title': 'बैटरी-अनुकूलित इनफरेंस',
      'off_s3_c2_body': 'वाणी फ्रेम-स्किपिंग लॉजिक का उपयोग करता है — हर 3rd–5th फ्रेम का विश्लेषण।',
      'off_s3_c3_title': 'Android 6.0+ और iOS 13+ पर काम करता है',
      'off_s3_c3_body': '₹6,000 का उपयोग किया हुआ Android फोन भी पूरी कार्यक्षमता पर वाणी चला सकता है।',
      'off_quote': 'प्रौद्योगिकी जो केवल तब काम करती है जब सब कुछ सही हो, वास्तविक दुनिया के लिए नहीं है।',
      'off_quote_src': 'वाणी इंजीनियरिंग सिद्धांत — डिज़ाइन द्वारा लचीलापन',
      'off_s4_title': 'ऑफलाइन क्षमता रोडमैप',
      'off_t1_year': 'v1.0', 'off_t1_event': 'मूल ISL वर्णमाला — 16,000 नमूनों पर प्रशिक्षित',
      'off_t2_year': 'v1.5', 'off_t2_event': 'वाक्य-स्तरीय पहचान — लंबे अनुक्रमों के लिए',
      'off_t3_year': 'v2.0', 'off_t3_event': 'क्षेत्रीय बोली समर्थन',
      'off_t4_year': 'v2.5', 'off_t4_event': 'दो-तरफा ऑफलाइन अनुवाद',

      // ── EDUCATION (Hindi)
      'edu_tag': '06', 'edu_category': 'शिक्षा',
      'edu_title': 'रियल-टाइम AI\nफीडबैक से\nISL सीखें',
      'edu_subtitle': 'वाणी हर फोन को ISL लर्निंग टूल बनाता है।',
      'edu_stat1_val': '<1%', 'edu_stat1_label': 'DHH कॉलेज पहुंचते हैं', 'edu_stat1_desc': 'पूरे भारत में',
      'edu_stat2_val': '5%', 'edu_stat2_label': 'DHH बच्चे स्कूल में', 'edu_stat2_desc': 'एक विनाशकारी अंतराल',
      'edu_stat3_val': '387', 'edu_stat3_label': 'भारत में बधिर स्कूल', 'edu_stat3_desc': '6 करोड़ के लिए — अपर्याप्त',
      'edu_stat4_val': '16K', 'edu_stat4_label': 'प्रशिक्षण नमूने', 'edu_stat4_desc': 'वाणी मॉडल डेटासेट',
      'edu_s1_title': 'भारत का DHH शिक्षा संकट',
      'edu_s1_c1_title': 'केवल 5% बधिर बच्चे स्कूल में हैं',
      'edu_s1_c1_body': 'भारत में केवल 5% बधिर बच्चे किसी भी प्रकार के स्कूल में नामांकित हैं।',
      'edu_s1_c2_title': 'मौखिकवाद का जाल',
      'edu_s1_c2_body': 'भारत के बधिर स्कूल मुख्य रूप से मौखिकवाद का उपयोग करते हैं।',
      'edu_s1_c3_title': 'शिक्षक की कमी गंभीर है',
      'edu_s1_c3_body': 'भारत में 387 बधिर स्कूलों के लिए पर्याप्त ISL-प्रशिक्षित शिक्षक नहीं हैं।',
      'edu_s2_title': 'शिक्षा परिणाम डेटा',
      'edu_bar1': 'माध्यमिक शिक्षा स्तर से नीचे DHH', 'edu_bar2': 'भाषण विकलांगता के साथ DHH माध्यमिक से नीचे',
      'edu_bar3': 'कोई शिक्षा नहीं पाने वाले ग्रामीण DHH बच्चे', 'edu_bar4': 'उच्च माध्यमिक पहुंचने वाले DHH',
      'edu_bar5': 'कॉलेज या उससे ऊपर पहुंचने वाले DHH',
      'edu_s3_title': 'एक शैक्षणिक उपकरण के रूप में वाणी',
      'edu_s3_c1_title': 'शिक्षार्थियों के लिए रियल-टाइम साइन फीडबैक',
      'edu_s3_c1_body': 'ISL सीखने वाला छात्र वाणी के कैमरे के सामने साइन कर सकता है और तुरंत देख सकता है।',
      'edu_s3_c2_title': 'कक्षा संचार सहायता',
      'edu_s3_c2_body': 'मुख्यधारा के स्कूल में DHH छात्र वाणी का उपयोग कर सकता है।',
      'edu_s3_c3_title': 'दोहराव पहचान के माध्यम से शब्दावली निर्माण',
      'edu_s3_c3_body': 'वाणी एक सत्र में सही ढंग से पहचाने गए संकेतों को स्थानीय रूप से लॉग करता है।',
      'edu_quote': 'हम विश्वास के साथ नहीं कह सकते कि 10% बधिर बच्चे किसी भी प्रकार के स्कूलों में हैं।',
      'edu_quote_src': 'भारतीय पुनर्वास परिषद — विकलांगता पहचान रिपोर्ट',
      'edu_s4_title': 'नीति और शैक्षणिक मील के पत्थर',
      'edu_t1_year': '1964', 'edu_t1_event': 'कोठारी आयोग — विकलांगता शिक्षा ढांचे में बदलाव',
      'edu_t2_year': '2001', 'edu_t2_event': 'भारत में पहली औपचारिक ISL कक्षाएं',
      'edu_t3_year': '2009', 'edu_t3_event': 'RTE अधिनियम — हर विकलांग बच्चे के लिए मुफ्त शिक्षा का अधिकार',
      'edu_t4_year': '2015', 'edu_t4_event': 'ISLRTC की स्थापना — ISL शिक्षकों को प्रशिक्षित करने की योजना',
      'edu_t5_year': '2020', 'edu_t5_event': 'NEP 2020 — देशभर में ISL शिक्षण की सिफारिश',
      'edu_t6_year': '2026', 'edu_t6_event': 'वाणी v1.0 — भारत के हर स्मार्टफोन उपयोगकर्ता के लिए AI-संचालित ISL टूल',
    },

    // ═══════════════════════════════════════════════════
    //  MARATHI
    // ═══════════════════════════════════════════════════
    'mr': {
      // ── Navbar
      'nav_home': 'मुख्य',
      'nav_terminal': 'टर्मिनल',
      'nav_api': 'एपीआय',
      'nav_language': 'भाषा',
      'nav_signs': 'संकेत',

      // ── Badge
      'badge': 'वाणी व्हिजन — 16k डेटासेट प्रशिक्षित',

      // ── Hero
      'hero_title_1': 'सांकेतिक ',
      'hero_title_highlight': 'भाषा ',
      'hero_title_2': 'मजकूरात बदला,\nरिअल-टाइममध्ये.',
      'hero_sub':
          'ऑन-डिव्हाइस AI द्वारे भारतातील बधिर समुदायाला सक्षम करणे.\nअचूकतेसाठी बनवलेले. सन्मानासाठी डिझाइन.',
      'get_started': 'टर्मिनल उघडा',

      // ── Stats
      'stat_mute_label': 'भारतातील बधिर व मूकबधिर',
      'stat_isl_label': 'ISL वापरकर्ते',
      'stat_translators_label': 'प्रमाणित दुभाषे',

      // ── Objectives grid
      'obj_heading': 'आम्ही कशासाठी उभे आहोत',
      'obj_sub': 'उद्देशाने बनवलेले. परिणामासाठी डिझाइन.',
      'obj_accessibility': 'प्रवेशयोग्यता',
      'obj_accessibility_desc': 'सर्वांसाठी संवादाचे अडथळे दूर करणे',
      'obj_bridging': 'दरी कमी करणे',
      'obj_bridging_desc': 'बधिर व श्रवण समुदायांना जोडणे',
      'obj_inclusivity': 'सर्वसमावेशकता',
      'obj_inclusivity_desc': 'प्रत्येक भाषेसाठी डिजिटल जग',
      'obj_privacy': 'गोपनीयता प्रथम',
      'obj_privacy_desc': '100% ऑन-डिव्हाइस — तुमचा डेटा कधीच बाहेर जात नाही',
      'obj_offline': 'ऑफलाइन तयार',
      'obj_offline_desc': 'इंटरनेटशिवायही काम करते',
      'obj_education': 'शिक्षण',
      'obj_education_desc': 'रिअल-टाइम AI फीडबॅकने ISL शिका',

      // ── Vision
      'vision_title': 'वाणी AI ने मौनाला शक्ती',
      'vision_body':
          'भारतात प्रत्येक 33,000+ बधिर व मूकबधिर व्यक्तींमागे केवळ 1 प्रमाणित दुभाषा आहे. वाणी ही दरी भरतो — थेट तुमच्या डिव्हाइसवर रिअल-टाइम अनुवाद.',

      // ── Translate Screen
      'translate_vision_title': 'AI व्हिजन स्ट्रीम',
      'translate_vision_sub': 'रिअल-टाइम सांकेतिक भाषा डेटा प्रक्रिया होत आहे',
      'translate_prediction': 'रिअल-टाइम अंदाज',
      'translate_waiting': 'प्रतीक्षा...',
      'translate_transcription': 'ट्रान्सक्रिप्शन',
      'translate_hint': 'ओळखलेले संकेत येथे दिसतील...',
      'translate_start': 'कॅप्चर सुरू करा',
      'translate_switch': 'बदला',
      'translate_cam_on': 'चालू',
      'translate_cam_off': 'बंद',

      // ── Dialog
      'dialog_title': 'वाणी कोर तयार',
      'dialog_body':
          'कॅमेरा टॉगल करून AI मॉड्यूल सुरू करा. अचूक भाषांतरासाठी हात फ्रेममध्ये ठेवा.',
      'dialog_btn': 'मॉड्यूल इनिशियलाइज करा',

      // ── Language names
      'lang_en': 'English',
      'lang_hi': 'हिन्दी',
      'lang_mr': 'मराठी',

      // ── Shared UI
      'obj_page_back': 'मुख्यपृष्ठावर परत',
      'obj_page_explore': 'जाणून घ्या →',
      'obj_page_confidence': 'विश्वास',
      'obj_crisis_stat': '1 दुभाषा : 33,000+ लोक',
      'obj_quote_icon_label': 'उद्धरण',

      // ══════════════════════════════════════════
      //  SIGNS PAGE (MARATHI)
      // ══════════════════════════════════════════
      'signs_title_1': 'ISL ',
      'signs_title_highlight': 'खुणा ग्रंथालय',
      'signs_subtitle':
          'वाणीद्वारे समर्थित सर्व 64 भारतीय सांकेतिक भाषा खुणा पहा. हस्त आकार, अर्थ आणि वापर तपशील पाहण्यासाठी कोणत्याही कार्डवर टॅप करा.',

      'signs_stat_total':    'एकूण खुणा',
      'signs_stat_alphabet': 'वर्णमाला',
      'signs_stat_numbers':  'संख्या',
      'signs_stat_words':    'शब्द',

      'signs_search_hint': 'नाव, अर्थ किंवा श्रेणीनुसार शोधा…',
      'cat_all':            'सर्व',
      'cat_alphabet':       'वर्णमाला',
      'cat_numbers':        'संख्या',
      'cat_words':          'शब्द',

      'signs_showing_all':      'सर्व {n} खुणा दाखवत आहे',
      'signs_showing_filtered': '{total} पैकी {n} खुणा दाखवत आहे',

      'signs_no_results':     'कोणत्याही खुणा आढळल्या नाहीत',
      'signs_no_results_sub': 'शोध किंवा फिल्टर बदलून प्रयत्न करा',

      // Alphabet (Marathi)
      'sign_a_name': 'अक्षर A', 'sign_a_meaning': 'अक्षर A', 'sign_a_desc': 'बंद मुठ, अंगठा तर्जनीजवळ.',
      'sign_b_name': 'अक्षर B', 'sign_b_meaning': 'अक्षर B', 'sign_b_desc': 'चारही बोटे सरळ वर, अंगठा तळहातावर.',
      'sign_c_name': 'अक्षर C', 'sign_c_meaning': 'अक्षर C', 'sign_c_desc': 'हात C आकारात वाकवा.',
      'sign_d_name': 'अक्षर D', 'sign_d_meaning': 'अक्षर D', 'sign_d_desc': 'तर्जनी वर, बाकी बोटे वर्तुळ बनवतात.',
      'sign_e_name': 'अक्षर E', 'sign_e_meaning': 'अक्षर E', 'sign_e_desc': 'चारही बोटे मध्य सांध्यावर वाकलेली.',
      'sign_f_name': 'अक्षर F', 'sign_f_meaning': 'अक्षर F', 'sign_f_desc': 'तर्जनी व अंगठा वर्तुळ, तीन बोटे वर.',
      'sign_g_name': 'अक्षर G', 'sign_g_meaning': 'अक्षर G', 'sign_g_desc': 'तर्जनी व अंगठा क्षैतिज समांतर.',
      'sign_h_name': 'अक्षर H', 'sign_h_meaning': 'अक्षर H', 'sign_h_desc': 'तर्जनी व मध्यमा क्षैतिज एकत्र.',
      'sign_i_name': 'अक्षर I', 'sign_i_meaning': 'अक्षर I', 'sign_i_desc': 'फक्त करंगळी वर.',
      'sign_j_name': 'अक्षर J', 'sign_j_meaning': 'अक्षर J', 'sign_j_desc': 'करंगळीने हवेत J काढा.',
      'sign_k_name': 'अक्षर K', 'sign_k_meaning': 'अक्षर K', 'sign_k_desc': 'तर्जनी व मध्यमा V मध्ये, अंगठा मध्ये.',
      'sign_l_name': 'अक्षर L', 'sign_l_meaning': 'अक्षर L', 'sign_l_desc': 'तर्जनी वर, अंगठा बाहेर — L आकार.',
      'sign_m_name': 'अक्षर M', 'sign_m_meaning': 'अक्षर M', 'sign_m_desc': 'तीन बोटे अंगठ्यावर वाकलेली.',
      'sign_n_name': 'अक्षर N', 'sign_n_meaning': 'अक्षर N', 'sign_n_desc': 'दोन बोटे अंगठ्यावर वाकलेली.',
      'sign_o_name': 'अक्षर O', 'sign_o_meaning': 'अक्षर O', 'sign_o_desc': 'सर्व बोटे व अंगठा O बनवतात.',
      'sign_p_name': 'अक्षर P', 'sign_p_meaning': 'अक्षर P', 'sign_p_desc': 'तर्जनी व मध्यमा खाली, अंगठा बाहेर.',
      'sign_q_name': 'अक्षर Q', 'sign_q_meaning': 'अक्षर Q', 'sign_q_desc': 'तर्जनी व अंगठा खाली Q बनवतात.',
      'sign_r_name': 'अक्षर R', 'sign_r_meaning': 'अक्षर R', 'sign_r_desc': 'तर्जनी व मध्यमा एकमेकांवर क्रॉस.',
      'sign_s_name': 'अक्षर S', 'sign_s_meaning': 'अक्षर S', 'sign_s_desc': 'बंद मुठ, अंगठा बोटांसमोर.',
      'sign_t_name': 'अक्षर T', 'sign_t_meaning': 'अक्षर T', 'sign_t_desc': 'अंगठा तर्जनी व मध्यमेत.',
      'sign_u_name': 'अक्षर U', 'sign_u_meaning': 'अक्षर U', 'sign_u_desc': 'तर्जनी व मध्यमा एकत्र वर.',
      'sign_v_name': 'अक्षर V', 'sign_v_meaning': 'अक्षर V', 'sign_v_desc': 'तर्जनी व मध्यमा V मध्ये, तळहात बाहेर.',
      'sign_w_name': 'अक्षर W', 'sign_w_meaning': 'अक्षर W', 'sign_w_desc': 'तीन बोटे W बनवतात.',
      'sign_x_name': 'अक्षर X', 'sign_x_meaning': 'अक्षर X', 'sign_x_desc': 'तर्जनी हुक आकारात.',
      'sign_y_name': 'अक्षर Y', 'sign_y_meaning': 'अक्षर Y', 'sign_y_desc': 'अंगठा व करंगळी बाहेर.',
      'sign_z_name': 'अक्षर Z', 'sign_z_meaning': 'अक्षर Z', 'sign_z_desc': 'तर्जनीने हवेत Z काढा.',

      // Numbers (Marathi)
      'sign_0_name': 'संख्या 0', 'sign_0_meaning': 'शून्य', 'sign_0_desc': 'सर्व बोटे O बनवतात.',
      'sign_1_name': 'संख्या 1', 'sign_1_meaning': 'एक', 'sign_1_desc': 'फक्त तर्जनी वर.',
      'sign_2_name': 'संख्या 2', 'sign_2_meaning': 'दोन', 'sign_2_desc': 'तर्जनी व मध्यमा V मध्ये.',
      'sign_3_name': 'संख्या 3', 'sign_3_meaning': 'तीन', 'sign_3_desc': 'तीन बोटे वर.',
      'sign_4_name': 'संख्या 4', 'sign_4_meaning': 'चार', 'sign_4_desc': 'चार बोटे पसरून वर.',
      'sign_5_name': 'संख्या 5', 'sign_5_meaning': 'पाच', 'sign_5_desc': 'सर्व पाच बोटे पसरलेली.',
      'sign_6_name': 'संख्या 6', 'sign_6_meaning': 'सहा', 'sign_6_desc': 'करंगळी व अंगठा जोडलेले, तीन वर.',
      'sign_7_name': 'संख्या 7', 'sign_7_meaning': 'सात', 'sign_7_desc': 'अनामिका व अंगठा जोडलेले.',
      'sign_8_name': 'संख्या 8', 'sign_8_meaning': 'आठ', 'sign_8_desc': 'मध्यमा व अंगठा जोडलेले.',
      'sign_9_name': 'संख्या 9', 'sign_9_meaning': 'नऊ', 'sign_9_desc': 'तर्जनी व अंगठा वर्तुळ, बाकी वर.',

      // Words (Marathi)
      'sign_namaste_name': 'नमस्ते', 'sign_namaste_meaning': 'अभिवादन / आदर', 'sign_namaste_desc': 'दोन्ही तळवे छातीवर जोडलेले, बोटे वर.',
      'sign_hello_name': 'हॅलो', 'sign_hello_meaning': 'हॅलो / अभिवादन', 'sign_hello_desc': 'उघडा तळहात कपाळापर्यंत, मग बाहेर.',
      'sign_hi_name': 'हाय', 'sign_hi_meaning': 'हाय / अनौपचारिक अभिवादन', 'sign_hi_desc': 'उघडा हात खांद्याच्या उंचीवर हलवा.',
      'sign_howareyou_name': 'तुम्ही कसे आहात?', 'sign_howareyou_meaning': 'तुम्ही कसे आहात?', 'sign_howareyou_desc': 'वाकलेला हात छातीतून बाहेर, मग तर्जनी समोर.',
      'sign_quiet_name': 'शांत / मौन', 'sign_quiet_meaning': 'शांत / मौन', 'sign_quiet_desc': 'तर्जनी बंद ओठांवर ठेवा.',
      'sign_thanks_name': 'धन्यवाद', 'sign_thanks_meaning': 'धन्यवाद / कृतज्ञता', 'sign_thanks_desc': 'सपाट हात हनुवटीपासून बाहेर.',
      'sign_food_name': 'जेवण', 'sign_food_meaning': 'जेवण / खाणे', 'sign_food_desc': 'सर्व बोटांच्या टोकांनी तोंडाकडे वारंवार.',
      'sign_iloveyou_name': 'आय लव्ह यू', 'sign_iloveyou_meaning': 'मी तुझ्यावर प्रेम करतो/करते', 'sign_iloveyou_desc': 'तर्जनी, करंगळी व अंगठा बाहेर.',
      'sign_brother_name': 'भाऊ', 'sign_brother_meaning': 'भाऊ', 'sign_brother_desc': 'L हस्त आकार कपाळावर, मग खाली.',
      'sign_father_name': 'वडील / बाबा', 'sign_father_meaning': 'वडील', 'sign_father_desc': 'उघडा हात अंगठा कपाळावर.',
      'sign_mother_name': 'आई / माई', 'sign_mother_meaning': 'आई', 'sign_mother_desc': 'उघडा हात अंगठा हनुवटीवर.',
      'sign_water_name': 'पाणी', 'sign_water_meaning': 'पाणी', 'sign_water_desc': 'W हस्त आकार हनुवटीवर दोनदा.',
      'sign_what_name': 'काय?', 'sign_what_meaning': 'काय? / प्रश्न', 'sign_what_desc': 'तर्जनी पुढे-मागे हलवा.',
      'sign_please_name': 'कृपया', 'sign_please_meaning': 'कृपया / विनंती', 'sign_please_desc': 'छातीवर गोलाकार हालचाल.',
      'sign_help_name': 'मदत / SOS', 'sign_help_meaning': 'मदत / आपत्काल', 'sign_help_desc': 'सपाट हात मुठीखाली, दोन्ही वर.',
      'sign_loud_name': 'मोठा आवाज', 'sign_loud_meaning': 'मोठा आवाज / गोंगाट', 'sign_loud_desc': 'तर्जन्या कानांवर, मग हात बाहेर.',
      'sign_yours_name': 'तुमचे / तुम्ही', 'sign_yours_meaning': 'तुमचे / तुम्ही', 'sign_yours_desc': 'तर्जनी समोरच्या व्यक्तीकडे.',
      'sign_sleeping_name': 'झोपणे', 'sign_sleeping_meaning': 'झोप / झोपणे', 'sign_sleeping_desc': 'उघडा हात चेहऱ्यासमोरून खाली.',
      'sign_name_name': 'नाव', 'sign_name_meaning': 'नाव / तुमचे नाव काय?', 'sign_name_desc': 'H हस्त आकार दुसऱ्या H वर दोनदा.',
      'sign_sorry_name': 'माफ करा', 'sign_sorry_meaning': 'माफी / क्षमा', 'sign_sorry_desc': 'बंद मुठ छातीवर गोलाकार.',
      'sign_good_name': 'चांगले', 'sign_good_meaning': 'चांगले / शाब्बास', 'sign_good_desc': 'सपाट हात ओठांपासून पुढे.',
      'sign_bad_name': 'वाईट', 'sign_bad_meaning': 'वाईट / चुकीचे', 'sign_bad_desc': 'सपाट हात ओठांपासून खाली.',
      'sign_today_name': 'आज', 'sign_today_meaning': 'आज / आत्ता', 'sign_today_desc': 'Y हस्त आकार कमरेपासून खाली.',
      'sign_time_name': 'वेळ', 'sign_time_meaning': 'वेळ / घड्याळ', 'sign_time_desc': 'तर्जनी मनगटावर दोनदा.',
      'sign_strong_name': 'मजबूत', 'sign_strong_meaning': 'मजबूत / शक्तिशाली', 'sign_strong_desc': 'C हस्त आकार खांद्यापासून मुठीत.',
      'sign_love_name': 'प्रेम', 'sign_love_meaning': 'प्रेम / आपुलकी', 'sign_love_desc': 'दोन्ही हात छातीवर क्रॉस.',
      'sign_bandaid_name': 'डॉक्टर / वैद्यकीय', 'sign_bandaid_meaning': 'डॉक्टर / वैद्यकीय मदत', 'sign_bandaid_desc': 'M हस्त आकार मनगटाच्या आतील बाजूस.',
      'sign_happy_name': 'आनंदी', 'sign_happy_meaning': 'आनंदी / खूश', 'sign_happy_desc': 'छातीवर गोलाकार वर.',

      // ── ACCESSIBILITY (Marathi)
      'acc_tag': '01', 'acc_category': 'प्रवेशयोग्यता',
      'acc_title': 'संवादाचे\nअडथळे\nदूर करणे',
      'acc_subtitle': '6 कोटींहून अधिक बधिर भारतीयांसाठी प्रत्येक संवाद एका पुलाची मागणी करतो. वाणी तो पूल आहे.',
      'acc_stat1_val': '6.3 कोटी+', 'acc_stat1_label': 'भारतातील बधिर', 'acc_stat1_desc': 'जगातील सर्वात मोठी अशी लोकसंख्या',
      'acc_stat2_val': '5%', 'acc_stat2_label': 'शाळेतील मुले', 'acc_stat2_desc': 'कोणत्याही प्रकारच्या शिक्षणात नोंदणीकृत',
      'acc_stat3_val': '26%', 'acc_stat3_label': 'रोजगार दर', 'acc_stat3_desc': 'सक्रिय रोजगारातील DHH प्रौढ',
      'acc_stat4_val': '387', 'acc_stat4_label': 'बधिर शाळा', 'acc_stat4_desc': '6 कोटींच्या लोकसंख्येसाठी',
      'acc_s1_title': 'प्रवेशयोग्यतेचे संकट',
      'acc_s1_c1_title': 'संवाद हा मानवी हक्क आहे — दररोज नाकारला जातो',
      'acc_s1_c1_body': 'प्रत्येक 33,000+ वापरकर्त्यांसाठी केवळ 1 प्रमाणित दुभाषा आहे.',
      'acc_s1_c2_title': 'शहरी–ग्रामीण विभाजन',
      'acc_s1_c2_body': 'बहुतेक 387 बधिर शाळा शहरी केंद्रांमध्ये आहेत. महाराष्ट्रातील कुटुंबे शिक्षणासाठी शहरांमध्ये स्थलांतरित झाली.',
      'acc_s1_c3_title': 'शब्दांशिवाय आरोग्यसेवा',
      'acc_s1_c3_body': 'सांकेतिक भाषा सहाय्याशिवाय वैद्यकीय सल्लामसलत चुकीचे निदान आणि विलंबित उपचारांकडे नेते.',
      'acc_s2_title': 'वाणी ज्या अडथळ्यांना लक्ष्य करते',
      'acc_bar1': 'सार्वजनिक वाहतूक आणि नेव्हिगेशन', 'acc_bar2': 'आरोग्यसेवा संवाद',
      'acc_bar3': 'कामाच्या ठिकाणी संवाद', 'acc_bar4': 'सरकारी सेवांमध्ये प्रवेश',
      'acc_bar5': 'शैक्षणिक सहभाग', 'acc_bar6': 'आपत्कालीन सेवा',
      'acc_s3_title': 'वाणी अडथळे कसे तोडतो',
      'acc_s3_c1_title': 'ऑन-डिव्हाइस, शून्य विलंब भाषांतर',
      'acc_s3_c1_body': 'वाणी संपूर्णपणे ऑन-डिव्हाइस सांकेतिक भाषा फ्रेम प्रक्रिया करतो.',
      'acc_s3_c2_title': 'दुभाषा आवश्यक नाही',
      'acc_s3_c2_body': 'वाणी कोणत्याही Android/iOS डिव्हाइसवर ₹0 टूल म्हणून प्रवेश लोकशाहीकरण करतो.',
      'acc_quote': 'अपंगत्व व्यक्तीमध्ये नाही — ते वातावरणात आहे. जेव्हा आपण वातावरणातून अडथळे काढतो, तेव्हा अपंगत्व नाहीसे होते.',
      'acc_quote_src': 'अपंगत्वाचे सामाजिक मॉडेल — अपंग व्यक्तींच्या हक्कांवर UN अधिवेशन',
      'acc_s4_title': 'भारतातील कायदेशीर चौकट',
      'acc_t1_year': '1992', 'acc_t1_event': 'भारतीय पुनर्वसन परिषद कायदा — अपंगत्व पुनर्वसनासाठी पहिले वैधानिक मंडळ',
      'acc_t2_year': '1995', 'acc_t2_event': 'अपंग व्यक्ती कायदा — समान संधी आणि सर्वसमावेशक शिक्षणाचे आदेश',
      'acc_t3_year': '2015', 'acc_t3_event': 'ISLRTC ची स्थापना — भारतीय सांकेतिक भाषा संशोधन व प्रशिक्षण केंद्र',
      'acc_t4_year': '2016', 'acc_t4_event': 'RPwD कायदा 2016 — विस्तारित अपंगत्व व्याख्या, 21 श्रेणी',
      'acc_t5_year': '2020', 'acc_t5_event': 'NEP 2020 — सर्व शाळांमध्ये ISL शिक्षणाची शिफारस',

      // ── BRIDGING GAPS (Marathi)
      'bridge_tag': '02', 'bridge_category': 'दरी कमी करणे',
      'bridge_title': 'बधिर व श्रवण\nसमुदायांना\nजोडणे',
      'bridge_subtitle': 'वाणी तो रिअल-टाइम पायाभूत सुविधा बांधतो जे दोन्ही जगांना एकत्र जोडतो.',
      'bridge_stat1_val': '1.8 कोटी', 'bridge_stat1_label': 'वास्तविक DHH लोकसंख्या', 'bridge_stat1_desc': 'NAD भारतानुसार',
      'bridge_stat2_val': '73.9%', 'bridge_stat2_label': 'सीमांत कामगार', 'bridge_stat2_desc': '15–59 वयोगटातील DHH भारतीय',
      'bridge_stat3_val': '1:33K', 'bridge_stat3_label': 'दुभाषा गुणोत्तर', 'bridge_stat3_desc': 'प्रति 33,000 वापरकर्त्यांमागे 1 दुभाषा',
      'bridge_stat4_val': '300', 'bridge_stat4_label': 'बधिर शाळा', 'bridge_stat4_desc': 'ISL अभ्यासक्रमासह',
      'bridge_s1_title': 'दरी का आहे',
      'bridge_s1_c1_title': 'ISL अद्याप अधिकृत भाषा नाही',
      'bridge_s1_c1_body': 'भारतीय सांकेतिक भाषा 80 लाखांहून अधिक लोक वापरतात पण त्याला संवैधानिक मान्यता नाही.',
      'bridge_s1_c2_title': 'शाळांमध्ये मौखिकवाद विरुद्ध सांकेतिक भाषा',
      'bridge_s1_c2_body': 'बहुतेक भारतीय बधिर शाळा "मौखिकवाद" वापरतात — मुलांना ओठ वाचणे शिकवतात.',
      'bridge_s1_c3_title': 'मौनाचा कलंक',
      'bridge_s1_c3_body': 'संशोधनात असे आढळले की महाराष्ट्रातील कुटुंबे बधिरपणाबद्दल "लाजिरवाणे" होती.',
      'bridge_s2_title': 'सामुदायिक एकीकरण डेटा',
      'bridge_bar1': 'ISL भाषांतरात प्रवेश असलेले DHH', 'bridge_bar2': 'स्मार्टफोन वापरणारे DHH',
      'bridge_bar3': 'कोणतीही सांकेतिक भाषा जाणणारे श्रवण लोक', 'bridge_bar4': 'औपचारिक रोजगारातील DHH',
      'bridge_bar5': 'माध्यमिक+ शिक्षण असलेले DHH',
      'bridge_s3_title': 'ब्रिज प्रोटोकॉल म्हणून वाणी',
      'bridge_s3_c1_title': 'द्विमार्गी संवाद स्तर',
      'bridge_s3_c1_body': 'वाणी एक सामायिक संवाद इंटरफेस तयार करतो. DHH व्यक्ती साइन करतो; श्रवण व्यक्ती वाचतो.',
      'bridge_s3_c2_title': 'रोजगार पूल',
      'bridge_s3_c2_body': 'वाणीसह, नोकरी मुलाखती, कामाच्या ठिकाणी बैठका आणि ग्राहक संवाद शक्य होतात.',
      'bridge_quote': 'खरी दरी बधिर आणि श्रवण लोकांमध्ये नाही — ती ज्यांच्याकडे संवाद साधने आहेत आणि ज्यांच्याकडे नाहीत त्यांच्यात आहे.',
      'bridge_quote_src': 'नॅशनल असोसिएशन ऑफ द डेफ, भारत',
      'bridge_s4_title': 'पूल बांधणीची कालरेषा',
      'bridge_t1_year': '2011', 'bridge_t1_event': 'IGNOU येथे ISLRTC ची स्थापना',
      'bridge_t2_year': '2017', 'bridge_t2_event': 'सरकारने ISL शब्दकोशात संहिताबद्ध केले — 3,000+ खुणा',
      'bridge_t3_year': '2018', 'bridge_t3_event': 'ISLRTC ने ISL शब्दकोश प्रकाशित केला',
      'bridge_t4_year': '2023', 'bridge_t4_event': 'केंब्रिज विद्यापीठाने ISL ला अधिकृत भाषा करण्याची मागणी केली',
      'bridge_t5_year': '2026', 'bridge_t5_event': 'वाणी AI — भारतातील प्रत्येक स्मार्टफोन वापरकर्त्यासाठी रिअल-टाइम ISL',

      // ── INCLUSIVITY (Marathi)
      'incl_tag': '03', 'incl_category': 'सर्वसमावेशकता',
      'incl_title': 'एक डिजिटल\nजग जे प्रत्येक\nभाषा बोलते',
      'incl_subtitle': 'भारतात 121 प्रमुख भाषा आहेत. अधिकृतपणे मान्यताप्राप्त सांकेतिक भाषा शून्य आहेत.',
      'incl_stat1_val': '121', 'incl_stat1_label': 'भारतातील भाषा', 'incl_stat1_desc': 'देशभर बोलल्या जातात',
      'incl_stat2_val': '0', 'incl_stat2_label': 'अधिकृत सांकेतिक भाषा', 'incl_stat2_desc': 'ISL ला संवैधानिक दर्जा नाही',
      'incl_stat3_val': '19%+', 'incl_stat3_label': 'शाळेबाहेर DHH मुले', 'incl_stat3_desc': '2014 सरकारी सर्वेक्षण',
      'incl_stat4_val': '₹23,000Cr', 'incl_stat4_label': 'सहाय्यक उपकरण बाजार', 'incl_stat4_desc': '2030 पर्यंत अंदाजे मूल्य',
      'incl_s1_title': 'सर्वसमावेशक भारत कसा दिसतो',
      'incl_s1_c1_title': 'डिजिटल इंडियाचा विरोधाभास',
      'incl_s1_c1_body': 'डिजिटल इंडिया कार्यक्रमाने 90 कोटी लोकांना इंटरनेटशी जोडले. तरीही 6 कोटी DHH नागरिकांसाठी बहुतेक डिजिटल इंटरफेस अगम्य राहतात.',
      'incl_s1_c2_title': 'सार्वजनिक वाहतूक आणि दैनंदिन नेव्हिगेशन',
      'incl_s1_c2_body': 'मेट्रो घोषणा, बस थांबे PA प्रणाली — सर्व केवळ ऑडिओवर अवलंबून आहेत.',
      'incl_s1_c3_title': 'दूरदर्शन आणि माध्यमांमधून वगळणे',
      'incl_s1_c3_body': 'भारतात सर्व बातम्या प्रसारणांवर सांकेतिक भाषा विंडो अनिवार्य नाही.',
      'incl_s2_title': 'क्षेत्रानुसार सर्वसमावेशकता अंतर',
      'incl_bar1': 'DHH साठी सुलभ डिजिटल सेवा', 'incl_bar2': 'सांकेतिक भाषा अनुवादासह TV प्रसारण',
      'incl_bar3': 'ISL सहाय्यासह सरकारी कार्यालये', 'incl_bar4': 'सांकेत-सक्षम कर्मचारी असलेली रुग्णालये',
      'incl_bar5': 'DHH समावेश धोरणांसह कार्यस्थळे', 'incl_bar6': 'ISL-प्रशिक्षित शिक्षकांसह शाळा',
      'incl_s3_title': 'वाणीची सर्वसमावेशकता वास्तुकला',
      'incl_s3_c1_title': 'बहुभाषिक आउटपुट — हिंदी, इंग्रजी, मराठी',
      'incl_s3_c1_body': 'वाणी वापरकर्त्याला आवश्यक असलेल्या भाषेत आउटपुट देतो.',
      'incl_s3_c2_title': 'कमी-किमतीच्या डिव्हाइससाठी डिझाइन',
      'incl_s3_c2_body': 'वाणी एज इनफरेन्ससाठी ऑप्टिमाइज केलेले आहे — हलके मॉडेल वेट आणि बॅटरी-कार्यक्षम संगणनासह.',
      'incl_quote': 'सर्वसमावेशक डिझाइन अपंगांसाठी वैशिष्ट्ये जोडण्याबद्दल नाही. हे मानवी विविधतेच्या पूर्ण श्रेणीसाठी डिझाइन करण्याबद्दल आहे.',
      'incl_quote_src': 'अपंग व्यक्तींच्या हक्कांवर UN अधिवेशन — अनुच्छेद 9',
      'incl_s4_title': 'जागतिक सर्वसमावेशकता मानके',
      'incl_t1_year': 'USA', 'incl_t1_event': 'ADA (1990) — सर्व फेडरल सेवांमध्ये सांकेतिक भाषा प्रवेश अनिवार्य',
      'incl_t2_year': 'UK', 'incl_t2_event': 'BSL ला 2022 मध्ये अधिकृत भाषा म्हणून मान्यता',
      'incl_t3_year': 'NZ', 'incl_t3_event': 'NZSL तीन अधिकृत भाषांपैकी एक आहे',
      'incl_t4_year': 'IND', 'incl_t4_event': 'RPwD कायदा 2016 — ISL अद्याप अधिकृत दर्जाशिवाय',
      'incl_t5_year': '2030', 'incl_t5_event': 'भारताचा सहाय्यक उपकरण बाजार ₹23,000 कोटींपर्यंत पोहोचण्याचा अंदाज',

      // ── PRIVACY (Marathi)
      'priv_tag': '04', 'priv_category': 'गोपनीयता प्रथम',
      'priv_title': '100% ऑन-डिव्हाइस.\nतुमचा डेटा\nकधीच जात नाही.',
      'priv_subtitle': 'वाणी सर्व काही तुमच्या डिव्हाइसवर प्रक्रिया करतो. शून्य क्लाउड. शून्य लॉग.',
      'priv_stat1_val': '0 बाइट', 'priv_stat1_label': 'सर्व्हरला पाठवलेला डेटा', 'priv_stat1_desc': 'सर्व इनफरेन्स स्थानिकरित्या चालते',
      'priv_stat2_val': '0ms', 'priv_stat2_label': 'नेटवर्क विलंब', 'priv_stat2_desc': 'कोणतेही क्लाउड राउंड-ट्रिप नाही',
      'priv_stat3_val': '100%', 'priv_stat3_label': 'ऑन-डिव्हाइस प्रक्रिया', 'priv_stat3_desc': 'कॅमेरा फ्रेम कधीही प्रसारित नाहीत',
      'priv_stat4_val': 'DPDP', 'priv_stat4_label': 'भारत डेटा संरक्षण', 'priv_stat4_desc': 'DPDP कायदा 2023 नुसार अनुपालन',
      'priv_s1_title': 'DHH साठी गोपनीयता का जास्त महत्त्वाची आहे',
      'priv_s1_c1_title': 'वैद्यकीय गोपनीयता अनिवार्य आहे',
      'priv_s1_c1_body': 'जेव्हा एखादा DHH रुग्ण डॉक्टरांना लक्षणांबद्दल साइन करतो — ती संभाषण खूप खाजगी असते.',
      'priv_s1_c2_title': 'कायदेशीर आणि आर्थिक संभाषणे',
      'priv_s1_c2_body': 'वाणीच्या ऑन-डिव्हाइस मॉडेलसह, जे साइन केले जाते ते फक्त वापरकर्त्याच्या डिव्हाइसवर राहते.',
      'priv_s1_c3_title': 'उपेक्षित समुदायांसाठी पाळत ठेवण्याचा धोका',
      'priv_s1_c3_body': 'ऑन-डिव्हाइस प्रक्रिया हा धोका पूर्णपणे दूर करते.',
      'priv_s2_title': 'वाणीची गोपनीयता वास्तुकला',
      'priv_s2_c1_title': 'एज इनफरेन्स — TFLite / ONNX Runtime',
      'priv_s2_c1_body': 'वाणीचे सांकेतिक भाषा मॉडेल ऑन-डिव्हाइस TensorFlow Lite किंवा ONNX फाइल म्हणून चालते.',
      'priv_s2_c2_title': 'कोणतेही खाते नाही. कोणतेही लॉगिन नाही. कोणताही ट्रॅकिंग नाही.',
      'priv_s2_c2_body': 'वाणीला शून्य वापरकर्ता नोंदणी आवश्यक आहे.',
      'priv_s2_c3_title': 'DPDP कायदा 2023 — डिझाइनद्वारे अनुपालन',
      'priv_s2_c3_body': 'वाणी कोणताही वैयक्तिक डेटा गोळा करत नाही.',
      'priv_quote': 'गोपनीयता काही लपवण्याबद्दल नाही. हे काही संरक्षण करण्याबद्दल आहे — तुमची देहबोली, तुमच्या कमकुवतपणा, तुमची मानवता.',
      'priv_quote_src': 'वाणी डिझाइन तत्त्वज्ञान — वास्तुकलेद्वारे गोपनीयता',
      'priv_s3_title': 'गोपनीयता तुलना',
      'priv_bar1': 'वाणी — क्लाउडवर पाठवलेला डेटा', 'priv_bar2': 'प्रतिस्पर्धी A — डेटा प्रेषित',
      'priv_bar3': 'प्रतिस्पर्धी B — डेटा अंशतः पाठवला', 'priv_bar4': 'पारंपरिक दुभाषा — गोपनीयता धोका',
      'priv_bar5': 'वाणी — इनफरेन्स विलंब तुलना',
      'priv_s4_title': 'तांत्रिक गोपनीयता हमी',
      'priv_t1_year': 'पायरी 1', 'priv_t1_event': 'कॅमेरा उघडतो — फ्रेम फक्त RAM मध्ये प्रक्रिया.',
      'priv_t2_year': 'पायरी 2', 'priv_t2_event': 'फ्रेम ऑन-डिव्हाइस मॉडेलला पास — कोणतेही नेटवर्क कॉल नाही.',
      'priv_t3_year': 'पायरी 3', 'priv_t3_event': 'अंदाज मजकूर स्ट्रिंग म्हणून परत — मूळ फ्रेम लगेच काढला जातो.',
      'priv_t4_year': 'पायरी 4', 'priv_t4_event': 'मजकूर स्क्रीनवर दाखवला जातो — कधीही सिंक नाही.',
      'priv_t5_year': 'पायरी 5', 'priv_t5_event': 'वापरकर्ता Delete दाबतो — मजकूर पुसला जातो.',

      // ── OFFLINE (Marathi)
      'off_tag': '05', 'off_category': 'ऑफलाइन तयार',
      'off_title': 'कुठेही काम\nकरते. इंटरनेट\nनाही. तडजोड नाही.',
      'off_subtitle': 'वाणी 0 kbps वर काम करते — नेहमी.',
      'off_stat1_val': '65%', 'off_stat1_label': 'ग्रामीण भारत कनेक्टिव्हिटी', 'off_stat1_desc': 'दूरस्थ जिल्ह्यांमध्ये मर्यादित किंवा 4G नाही',
      'off_stat2_val': '~25MB', 'off_stat2_label': 'मॉडेल आकार', 'off_stat2_desc': 'ऑन-डिव्हाइस संकुचित ISL मॉडेल',
      'off_stat3_val': '<50ms', 'off_stat3_label': 'इनफरेन्स वेळ', 'off_stat3_desc': 'मिड-टियर Android वर प्रति फ्रेम',
      'off_stat4_val': '80 लाख+', 'off_stat4_label': 'संभाव्य ग्रामीण वापरकर्ते', 'off_stat4_desc': 'कमी सेवा असलेल्या भागातील DHH',
      'off_s1_title': 'ग्रामीण कनेक्टिव्हिटी समस्या',
      'off_s1_c1_title': 'भारताची डिजिटल दरी वास्तविक आहे',
      'off_s1_c1_body': 'ग्रामीण भारतातील 65% हून अधिक भागात असंगत 4G कनेक्टिव्हिटी आहे.',
      'off_s1_c2_title': 'आपत्कालीन परिस्थिती सिग्नलची वाट पाहू शकत नाही',
      'off_s1_c2_body': 'ऑफलाइन ऑपरेशनचा अर्थ म्हणजे वाणी रुग्णालयात आणि दुर्गम गावांमध्ये सारखेच काम करते.',
      'off_s1_c3_title': 'कमी कनेक्टिव्हिटी क्षेत्रातील शाळा',
      'off_s1_c3_body': 'ऑफलाइन क्षमतेचा अर्थ वाणी शाळेच्या WiFi वर अवलंबून न राहता वापरला जाऊ शकतो.',
      'off_s2_title': 'DHH लोकसंख्येच्या तुलनेत कनेक्टिव्हिटी',
      'off_bar1': 'महानगर — कनेक्टिव्हिटी', 'off_bar2': 'टायर-2 शहरे — कनेक्टिव्हिटी',
      'off_bar3': 'टायर-3 शहरे — कनेक्टिव्हिटी', 'off_bar4': 'ग्रामीण भाग — कनेक्टिव्हिटी',
      'off_bar5': 'दुर्गम गावे — कनेक्टिव्हिटी', 'off_bar6': 'ग्रामीण भारतातील DHH लोकसंख्या',
      'off_s3_title': 'वाणीमध्ये ऑफलाइन कसे काम करते',
      'off_s3_c1_title': 'इन्स्टॉलवर बंडल मॉडेल — कोणतेही डाउनलोड आवश्यक नाही',
      'off_s3_c1_body': 'ISL ओळख मॉडेल (~25MB संकुचित) अॅप पॅकेजच्या आत येते.',
      'off_s3_c2_title': 'बॅटरी-अनुकूलित इनफरेन्स',
      'off_s3_c2_body': 'वाणी फ्रेम-स्किपिंग लॉजिक वापरते — प्रत्येक 3ऱ्या–5व्या फ्रेमचे विश्लेषण.',
      'off_s3_c3_title': 'Android 6.0+ आणि iOS 13+ वर काम करते',
      'off_s3_c3_body': '₹6,000 च्या वापरलेल्या Android फोनवरही वाणी पूर्ण कार्यक्षमतेवर चालू शकते.',
      'off_quote': 'तंत्रज्ञान जे फक्त तेव्हाच काम करते जेव्हा सर्वकाही परिपूर्ण असते ते वास्तविक जगासाठी नाही.',
      'off_quote_src': 'वाणी अभियांत्रिकी तत्त्वे — डिझाइनद्वारे लवचिकता',
      'off_s4_title': 'ऑफलाइन क्षमता रोडमॅप',
      'off_t1_year': 'v1.0', 'off_t1_event': 'मूळ ISL वर्णमाला — 16,000 नमुन्यांवर प्रशिक्षित',
      'off_t2_year': 'v1.5', 'off_t2_event': 'वाक्य-स्तरीय ओळख — मोठ्या खूण अनुक्रमांसाठी',
      'off_t3_year': 'v2.0', 'off_t3_event': 'प्रादेशिक बोली समर्थन',
      'off_t4_year': 'v2.5', 'off_t4_event': 'द्विमार्गी ऑफलाइन भाषांतर',

      // ── EDUCATION (Marathi)
      'edu_tag': '06', 'edu_category': 'शिक्षण',
      'edu_title': 'रिअल-टाइम AI\nफीडबॅकद्वारे\nISL शिका',
      'edu_subtitle': 'वाणी प्रत्येक फोनला ISL लर्निंग टूल बनवतो.',
      'edu_stat1_val': '<1%', 'edu_stat1_label': 'DHH महाविद्यालयात पोहोचतात', 'edu_stat1_desc': 'संपूर्ण भारतात',
      'edu_stat2_val': '5%', 'edu_stat2_label': 'DHH मुले शाळेत', 'edu_stat2_desc': 'एक विनाशकारी अंतर',
      'edu_stat3_val': '387', 'edu_stat3_label': 'भारतातील बधिर शाळा', 'edu_stat3_desc': '6 कोटींसाठी — अपुरे',
      'edu_stat4_val': '16K', 'edu_stat4_label': 'प्रशिक्षण नमुने', 'edu_stat4_desc': 'वाणी मॉडेल डेटासेट',
      'edu_s1_title': 'भारताचे DHH शिक्षण संकट',
      'edu_s1_c1_title': 'फक्त 5% बधिर मुले शाळेत आहेत',
      'edu_s1_c1_body': 'भारतात केवळ 5% बधिर मुले कोणत्याही प्रकारच्या शाळेत नोंदणीकृत आहेत.',
      'edu_s1_c2_title': 'मौखिकवादाचा सापळा',
      'edu_s1_c2_body': 'भारतातील बधिर शाळा प्रामुख्याने मौखिकवाद वापरतात.',
      'edu_s1_c3_title': 'शिक्षकांची तीव्र टंचाई',
      'edu_s1_c3_body': 'भारतात 387 बधिर शाळांसाठी पुरेसे ISL-प्रशिक्षित शिक्षक नाहीत.',
      'edu_s2_title': 'शिक्षण परिणाम डेटा',
      'edu_bar1': 'माध्यमिक शिक्षण पातळीच्या खाली DHH', 'edu_bar2': 'भाषण अपंगत्वासह DHH माध्यमिकच्या खाली',
      'edu_bar3': 'शिक्षण न मिळालेली ग्रामीण DHH मुले', 'edu_bar4': 'उच्च माध्यमिकपर्यंत पोहोचलेले DHH',
      'edu_bar5': 'महाविद्यालय किंवा त्यावर पोहोचलेले DHH',
      'edu_s3_title': 'शैक्षणिक साधन म्हणून वाणी',
      'edu_s3_c1_title': 'शिकणाऱ्यांसाठी रिअल-टाइम खूण फीडबॅक',
      'edu_s3_c1_body': 'ISL शिकणारा विद्यार्थी वाणीच्या कॅमेऱ्यासमोर साइन करू शकतो आणि लगेच पाहू शकतो.',
      'edu_s3_c2_title': 'वर्गखोली संवाद सहाय्य',
      'edu_s3_c2_body': 'मुख्यप्रवाहाच्या शाळेतील DHH विद्यार्थी वाणी वापरू शकतो.',
      'edu_s3_c3_title': 'पुनरावृत्ती ओळखीद्वारे शब्दसंग्रह निर्माता',
      'edu_s3_c3_body': 'वाणी एका सत्रात बरोबर ओळखल्या गेलेल्या खुणा स्थानिकरित्या नोंदवतो.',
      'edu_quote': 'आपण विश्वासाने सांगू शकत नाही की 10% बधिर मुले कोणत्याही प्रकारच्या शाळांमध्ये आहेत.',
      'edu_quote_src': 'भारतीय पुनर्वसन परिषद — अपंगत्व ओळख अहवाल',
      'edu_s4_title': 'धोरण आणि शैक्षणिक टप्पे',
      'edu_t1_year': '1964', 'edu_t1_event': 'कोठारी आयोग — अपंगत्व शिक्षण चौकटीत बदल',
      'edu_t2_year': '2001', 'edu_t2_event': 'भारतात पहिले औपचारिक ISL वर्ग',
      'edu_t3_year': '2009', 'edu_t3_event': 'RTE कायदा — प्रत्येक अपंग मुलासाठी मोफत शिक्षणाचा हक्क',
      'edu_t4_year': '2015', 'edu_t4_event': 'ISLRTC ची स्थापना — ISL शिक्षकांना प्रशिक्षण देण्याची योजना',
      'edu_t5_year': '2020', 'edu_t5_event': 'NEP 2020 — देशभर ISL शिक्षणाची शिफारस',
      'edu_t6_year': '2026', 'edu_t6_event': 'वाणी — भारतातील प्रत्येक स्मार्टफोन वापरकर्त्यासाठी AI-चालित ISL टूल',
    },
  };

  String t(String key) =>
      _localizedValues[locale.languageCode]?[key] ?? key;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) =>
      ['en', 'hi', 'mr'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async =>
      AppLocalizations(locale);

  @override
  bool shouldReload(_) => false;
}