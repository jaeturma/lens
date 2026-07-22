import { Link, usePage } from '@inertiajs/react';
import {
    BookOpen,
    CreditCard,
    FolderGit2,
    LayoutGrid,
    Megaphone,
    Radio,
    ScanLine,
    UserCog,
    Users,
} from 'lucide-react';
import AnnouncementController from '@/actions/App/Http/Controllers/Announcements/AnnouncementController';
import GuardianController from '@/actions/App/Http/Controllers/Guardians/GuardianController';
import RfidCardController from '@/actions/App/Http/Controllers/RfidCards/RfidCardController';
import RfidDeviceController from '@/actions/App/Http/Controllers/RfidDevices/RfidDeviceController';
import RfidScanController from '@/actions/App/Http/Controllers/RfidScans/RfidScanController';
import StudentController from '@/actions/App/Http/Controllers/Students/StudentController';
import AppLogo from '@/components/app-logo';
import { NavFooter } from '@/components/nav-footer';
import { NavMain } from '@/components/nav-main';
import { NavUser } from '@/components/nav-user';
import {
    Sidebar,
    SidebarContent,
    SidebarFooter,
    SidebarHeader,
    SidebarMenu,
    SidebarMenuButton,
    SidebarMenuItem,
} from '@/components/ui/sidebar';
import { dashboard } from '@/routes';
import type { Auth, NavItem } from '@/types';

const footerNavItems: NavItem[] = [
    {
        title: 'Repository',
        href: 'https://github.com/laravel/react-starter-kit',
        icon: FolderGit2,
    },
    {
        title: 'Documentation',
        href: 'https://laravel.com/docs/starter-kits#react',
        icon: BookOpen,
    },
];

export function AppSidebar() {
    const { auth } = usePage<{ auth: Auth }>().props;
    const isAdministrator =
        auth.user.role === 'system_administrator' ||
        auth.user.role === 'school_administrator';

    const mainNavItems: NavItem[] = [
        {
            title: 'Dashboard',
            href: dashboard(),
            icon: LayoutGrid,
        },
        ...(isAdministrator
            ? [
                  {
                      title: 'Students',
                      href: StudentController.index(),
                      icon: Users,
                  },
                  {
                      title: 'Guardians',
                      href: GuardianController.index(),
                      icon: UserCog,
                  },
                  {
                      title: 'RFID Devices',
                      href: RfidDeviceController.index(),
                      icon: Radio,
                  },
                  {
                      title: 'RFID Cards',
                      href: RfidCardController.index(),
                      icon: CreditCard,
                  },
                  {
                      title: 'RFID Scans',
                      href: RfidScanController.index(),
                      icon: ScanLine,
                  },
                  {
                      title: 'Announcements',
                      href: AnnouncementController.index(),
                      icon: Megaphone,
                  },
              ]
            : []),
    ];

    return (
        <Sidebar collapsible="icon" variant="inset">
            <SidebarHeader>
                <SidebarMenu>
                    <SidebarMenuItem>
                        <SidebarMenuButton size="lg" asChild>
                            <Link href={dashboard()} prefetch>
                                <AppLogo />
                            </Link>
                        </SidebarMenuButton>
                    </SidebarMenuItem>
                </SidebarMenu>
            </SidebarHeader>

            <SidebarContent>
                <NavMain items={mainNavItems} />
            </SidebarContent>

            <SidebarFooter>
                <NavFooter items={footerNavItems} className="mt-auto" />
                <NavUser />
            </SidebarFooter>
        </Sidebar>
    );
}
