import 'package:get/get.dart';
import '../../presentation/layouts/main_layout.dart';
import '../../presentation/pages/dashboard/analytics_dashboard.dart';
import '../../presentation/pages/dashboard/sales_dashboard.dart';
import '../../presentation/pages/dashboard/projects_dashboard.dart';
import '../../presentation/pages/dashboard/crypto_dashboard.dart';
import '../../presentation/pages/dashboard/crm_dashboard.dart';
import '../../presentation/pages/apps/chat_page.dart';
import '../../presentation/pages/apps/calendar_page.dart';
import '../../presentation/pages/apps/file_manager_page.dart';
import '../../presentation/pages/apps/kanban_board_page.dart';
import '../../presentation/pages/ecommerce/products_list_page.dart';
import '../../presentation/pages/ecommerce/add_product_page.dart';
import '../../presentation/pages/ecommerce/orders_page.dart';
import '../../presentation/pages/ecommerce/customers_page.dart';
import '../../presentation/pages/auth/login_page.dart';
import '../../presentation/pages/auth/register_page.dart';
import '../../presentation/pages/auth/forgot_password_page.dart';
import '../../presentation/pages/auth/reset_password_page.dart';
import '../../presentation/pages/auth/lock_screen_page.dart';
import '../../presentation/pages/errors/error_404_page.dart';
import '../../presentation/pages/errors/error_500_page.dart';
import '../../presentation/pages/main_things/master_data/add_master_data.dart';
import '../../presentation/pages/main_things/master_data/master_data_details_page.dart';
import '../../presentation/pages/main_things/master_data/master_data_list_page.dart';
import '../../presentation/pages/main_things/orders/add_orders_page.dart';
import '../../presentation/pages/main_things/orders/order_detail_page.dart';
import '../../presentation/pages/main_things/qualities/add_quality_page.dart';
import '../../presentation/pages/main_things/qualities/qualities_list_page.dart';
import '../../presentation/pages/main_things/qualities/quality_detail_page.dart';
import '../../presentation/pages/other/coming_soon_page.dart';
import '../../presentation/pages/other/faqs_page.dart';
import '../../presentation/pages/other/pricing_page.dart';
import '../../presentation/pages/other/timeline_page.dart';
import '../../presentation/pages/other/profile_page.dart';
import '../../presentation/pages/settings/appearance_page.dart';
import '../../presentation/pages/settings/privacy_and_security_page.dart';
import '../../presentation/pages/settings/notifications_page.dart';
import '../../presentation/pages/splash/splash_screen.dart';

class AppRouter {
  static final List<GetPage> routes = [
    GetPage(
      name: '/splash',
      page: () => const LoadingSplashScreen(),
      transition: Transition.fadeIn,
    ),
    // Dashboard Routes
    GetPage(
      name: '/analytics',
      page: () => const MainLayout(content: AnalyticsDashboard()),
      transition: Transition.fadeIn,
    ),

    // Order Routes
    GetPage(
      name: '/add-order',
      page: () =>  AddOrderPage(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: '/order-detail/:id',
      page: () {
        final orderId = Get.parameters['id'] ?? '';
        return  OrderDetailPage(orderId: orderId);
      },
      transition: Transition.fadeIn,
    ),

    // Quality Routes
    GetPage(
      name: '/qualities',
      page: () => const MainLayout(content: QualitiesListPage()),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: '/add-quality',
      page: () => const AddQualityPage(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: '/quality-detail/:id',
      page: () {
        final qualityId = Get.parameters['id'] ?? '';
        return QualityDetailPage(qualityId: qualityId);
      },
      transition: Transition.fadeIn,
    ),

    // Master data routes
    GetPage(
      name: '/master-data',
      page: () => const MainLayout(content: MasterDataListPage()),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: '/add-master-data',
      page: () => const AddMasterDataPage(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: '/master-data-detail/:id',
      page: () {
        final masterDataId = Get.parameters['id'] ?? '';
        return MainLayout(content: MasterDataDetailPage(masterDataId: masterDataId));
      },
      transition: Transition.fadeIn,
    ),

    GetPage(
      name: '/sales',
      page: () => const MainLayout(content: SalesDashboard()),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: '/projects',
      page: () => const MainLayout(content: ProjectsDashboard()),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: '/crypto',
      page: () => const MainLayout(content: CryptoDashboard()),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: '/crm',
      page: () => const MainLayout(content: CRMDashboard()),
      transition: Transition.fadeIn,
    ),
    
    // Apps Routes
    GetPage(
      name: '/chat',
      page: () => const MainLayout(content: ChatPage()),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: '/calendar',
      page: () => const MainLayout(content: CalendarPage(),showTopbar: false,),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: '/file-manager',
      page: () => const MainLayout(content: FileManagerPage()),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: '/kanban',
      page: () => const MainLayout(content: KanbanBoardPage()),
      transition: Transition.fadeIn,
    ),
    
    // E-Commerce Routes
    GetPage(
      name: '/products',
      page: () => const MainLayout(content: ProductsListPage()),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: '/add-product',
      page: () => const MainLayout(content: AddProductPage()),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: '/orders',
      page: () => const MainLayout(content: OrdersPage()),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: '/customers',
      page: () => const MainLayout(content: CustomersPage()),
      transition: Transition.fadeIn,
    ),
    
    // Auth Routes
    GetPage(
      name: '/login',
      page: () => const LoginPage(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: '/register',
      page: () => const RegisterPage(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: '/forgot-password',
      page: () => const ForgotPasswordPage(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: '/reset-password',
      page: () => const ResetPasswordPage(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: '/lock-screen',
      page: () => const LockScreenPage(),
      transition: Transition.fadeIn,
    ),
    
    // Error Pages
    GetPage(
      name: '/error-404',
      page: () => const Error404Page(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: '/error-500',
      page: () => const Error500Page(),
      transition: Transition.fadeIn,
    ),
    
    // Other Pages
    GetPage(
      name: '/coming-soon',
      page: () => const MainLayout(content: ComingSoonPage()),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: '/faqs',
      page: () => const MainLayout(content: FAQsPage()),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: '/pricing',
      page: () => const MainLayout(content: PricingPage()),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: '/timeline',
      page: () => const MainLayout(content: TimelinePage()),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: '/profile',
      page: () => const MainLayout(content: ProfilePage()),
      transition: Transition.fadeIn,
    ),
    
    // Settings Pages
    GetPage(
      name: '/settings/appearance',
      page: () => const MainLayout(content: AppearancePage()),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: '/settings/privacy',
      page: () => const MainLayout(content: PrivacyAndSecurityPage()),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: '/settings/notifications',
      page: () => const MainLayout(content: NotificationsPage()),
      transition: Transition.fadeIn,
    ),
  ];
}
