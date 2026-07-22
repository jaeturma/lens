import { Form, Head, Link, setLayoutProps } from '@inertiajs/react';
import AnnouncementController from '@/actions/App/Http/Controllers/Announcements/AnnouncementController';
import ExpireAnnouncementController from '@/actions/App/Http/Controllers/Announcements/ExpireAnnouncementController';
import PublishAnnouncementController from '@/actions/App/Http/Controllers/Announcements/PublishAnnouncementController';
import WithdrawAnnouncementController from '@/actions/App/Http/Controllers/Announcements/WithdrawAnnouncementController';
import Heading from '@/components/heading';
import { Badge } from '@/components/ui/badge';
import { Button } from '@/components/ui/button';
import type { Announcement } from '@/types';

type Props = {
    announcement: Announcement;
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

function Field({ label, value }: { label: string; value: string }) {
    return (
        <div>
            <dt className="text-sm text-muted-foreground">{label}</dt>
            <dd className="font-medium">{value}</dd>
        </div>
    );
}

export default function AnnouncementsShow({ announcement }: Props) {
    setLayoutProps({
        breadcrumbs: [
            { title: 'Announcements', href: AnnouncementController.index() },
            {
                title: announcement.title,
                href: AnnouncementController.show(announcement.id),
            },
        ],
    });

    return (
        <div className="max-w-xl space-y-6 p-4">
            <Head title={announcement.title} />

            <div className="flex items-center justify-between">
                <Heading
                    title={announcement.title}
                    description={`Created ${announcement.created_at}`}
                />
                <Badge variant={statusVariant[announcement.status]}>
                    {announcement.status}
                </Badge>
            </div>

            <p className="rounded-lg border p-4 text-sm whitespace-pre-wrap">
                {announcement.body}
            </p>

            <dl className="grid grid-cols-2 gap-4 rounded-lg border p-4">
                <Field
                    label="Published at"
                    value={announcement.published_at ?? 'Not published'}
                />
                <Field
                    label="Expires at"
                    value={announcement.expires_at ?? 'Never'}
                />
            </dl>

            <div className="flex items-center gap-2">
                <Button asChild variant="secondary">
                    <Link href={AnnouncementController.edit(announcement.id)}>
                        Edit
                    </Link>
                </Button>

                {announcement.status === 'draft' && (
                    <Form
                        {...PublishAnnouncementController.form(announcement.id)}
                        options={{ preserveScroll: true }}
                    >
                        {({ processing }) => (
                            <Button type="submit" disabled={processing}>
                                Publish
                            </Button>
                        )}
                    </Form>
                )}

                {announcement.status === 'published' && (
                    <>
                        <Form
                            {...WithdrawAnnouncementController.form(
                                announcement.id,
                            )}
                            options={{ preserveScroll: true }}
                        >
                            {({ processing }) => (
                                <Button
                                    type="submit"
                                    variant="destructive"
                                    disabled={processing}
                                >
                                    Withdraw
                                </Button>
                            )}
                        </Form>
                        <Form
                            {...ExpireAnnouncementController.form(
                                announcement.id,
                            )}
                            options={{ preserveScroll: true }}
                        >
                            {({ processing }) => (
                                <Button
                                    type="submit"
                                    variant="secondary"
                                    disabled={processing}
                                >
                                    Expire
                                </Button>
                            )}
                        </Form>
                    </>
                )}
            </div>
        </div>
    );
}
