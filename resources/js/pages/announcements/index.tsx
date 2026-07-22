import { Form, Link } from '@inertiajs/react';
import AnnouncementController from '@/actions/App/Http/Controllers/Announcements/AnnouncementController';
import ExpireAnnouncementController from '@/actions/App/Http/Controllers/Announcements/ExpireAnnouncementController';
import PublishAnnouncementController from '@/actions/App/Http/Controllers/Announcements/PublishAnnouncementController';
import WithdrawAnnouncementController from '@/actions/App/Http/Controllers/Announcements/WithdrawAnnouncementController';
import Heading from '@/components/heading';
import { Badge } from '@/components/ui/badge';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Label } from '@/components/ui/label';
import type { Announcement, AnnouncementFilters, Paginated } from '@/types';

type Props = {
    announcements: Paginated<Announcement>;
    filters: AnnouncementFilters;
};

const statusVariant: Record<
    Announcement['status'],
    'default' | 'secondary' | 'destructive' | 'outline'
> = {
    draft: 'secondary',
    published: 'default',
    expired: 'outline',
    withdrawn: 'destructive',
};

export default function AnnouncementsIndex({ announcements, filters }: Props) {
    return (
        <div className="space-y-6 p-4">
            <div className="flex items-center justify-between">
                <Heading
                    title="Announcements"
                    description="Manage school announcements"
                />
                <Button asChild>
                    <Link href={AnnouncementController.create()}>
                        New announcement
                    </Link>
                </Button>
            </div>

            <Form
                action={AnnouncementController.index.url()}
                method="get"
                options={{
                    preserveState: true,
                    preserveScroll: true,
                    replace: true,
                }}
                className="flex flex-wrap items-end gap-4"
            >
                <div className="grid gap-2">
                    <Label htmlFor="q">Search</Label>
                    <Input
                        id="q"
                        name="q"
                        placeholder="Title"
                        defaultValue={filters.q ?? ''}
                        className="w-64"
                    />
                </div>
                <div className="grid gap-2">
                    <Label htmlFor="status">Status</Label>
                    <select
                        id="status"
                        name="status"
                        defaultValue={filters.status ?? ''}
                        className="h-9 rounded-md border border-input bg-transparent px-3 py-1 text-sm shadow-xs"
                    >
                        <option value="">All</option>
                        <option value="draft">Draft</option>
                        <option value="published">Published</option>
                        <option value="expired">Expired</option>
                        <option value="withdrawn">Withdrawn</option>
                    </select>
                </div>
                <Button type="submit" variant="secondary">
                    Filter
                </Button>
            </Form>

            <div className="overflow-x-auto rounded-lg border">
                <table className="w-full text-sm">
                    <thead className="bg-muted/50 text-left">
                        <tr>
                            <th className="p-3 font-medium">Title</th>
                            <th className="p-3 font-medium">Status</th>
                            <th className="p-3 font-medium">Published</th>
                            <th className="p-3 font-medium">Expires</th>
                            <th className="p-3 font-medium">Actions</th>
                        </tr>
                    </thead>
                    <tbody>
                        {announcements.data.map((announcement) => (
                            <tr key={announcement.id} className="border-t">
                                <td className="p-3">
                                    <Link
                                        href={AnnouncementController.show(
                                            announcement.id,
                                        )}
                                        className="font-medium hover:underline"
                                    >
                                        {announcement.title}
                                    </Link>
                                </td>
                                <td className="p-3">
                                    <Badge
                                        variant={
                                            statusVariant[announcement.status]
                                        }
                                    >
                                        {announcement.status}
                                    </Badge>
                                </td>
                                <td className="p-3">
                                    {announcement.published_at ?? '—'}
                                </td>
                                <td className="p-3">
                                    {announcement.expires_at ?? '—'}
                                </td>
                                <td className="p-3">
                                    <div className="flex items-center gap-2">
                                        <Link
                                            href={AnnouncementController.edit(
                                                announcement.id,
                                            )}
                                            className="text-sm hover:underline"
                                        >
                                            Edit
                                        </Link>
                                        {announcement.status === 'draft' && (
                                            <Form
                                                {...PublishAnnouncementController.form(
                                                    announcement.id,
                                                )}
                                                options={{
                                                    preserveScroll: true,
                                                }}
                                            >
                                                {({ processing }) => (
                                                    <button
                                                        type="submit"
                                                        disabled={processing}
                                                        className="text-sm hover:underline"
                                                    >
                                                        Publish
                                                    </button>
                                                )}
                                            </Form>
                                        )}
                                        {announcement.status ===
                                            'published' && (
                                            <>
                                                <Form
                                                    {...WithdrawAnnouncementController.form(
                                                        announcement.id,
                                                    )}
                                                    options={{
                                                        preserveScroll: true,
                                                    }}
                                                >
                                                    {({ processing }) => (
                                                        <button
                                                            type="submit"
                                                            disabled={
                                                                processing
                                                            }
                                                            className="text-sm text-destructive hover:underline"
                                                        >
                                                            Withdraw
                                                        </button>
                                                    )}
                                                </Form>
                                                <Form
                                                    {...ExpireAnnouncementController.form(
                                                        announcement.id,
                                                    )}
                                                    options={{
                                                        preserveScroll: true,
                                                    }}
                                                >
                                                    {({ processing }) => (
                                                        <button
                                                            type="submit"
                                                            disabled={
                                                                processing
                                                            }
                                                            className="text-sm hover:underline"
                                                        >
                                                            Expire
                                                        </button>
                                                    )}
                                                </Form>
                                            </>
                                        )}
                                    </div>
                                </td>
                            </tr>
                        ))}
                        {announcements.data.length === 0 && (
                            <tr>
                                <td
                                    colSpan={5}
                                    className="p-6 text-center text-muted-foreground"
                                >
                                    No announcements found.
                                </td>
                            </tr>
                        )}
                    </tbody>
                </table>
            </div>

            {announcements.last_page > 1 && (
                <div className="flex flex-wrap items-center gap-1">
                    {announcements.links.map((link, index) => (
                        <Link
                            key={index}
                            href={link.url ?? '#'}
                            preserveScroll
                            className={
                                'rounded-md px-3 py-1 text-sm ' +
                                (link.active
                                    ? 'bg-primary text-primary-foreground'
                                    : 'hover:bg-accent') +
                                (link.url
                                    ? ''
                                    : ' pointer-events-none opacity-50')
                            }
                            dangerouslySetInnerHTML={{ __html: link.label }}
                        />
                    ))}
                </div>
            )}
        </div>
    );
}

AnnouncementsIndex.layout = {
    breadcrumbs: [
        {
            title: 'Announcements',
            href: AnnouncementController.index(),
        },
    ],
};
