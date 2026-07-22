import { Form, Head, setLayoutProps } from '@inertiajs/react';
import AnnouncementController from '@/actions/App/Http/Controllers/Announcements/AnnouncementController';
import Heading from '@/components/heading';
import InputError from '@/components/input-error';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Label } from '@/components/ui/label';
import type { Announcement } from '@/types';

type Props = {
    announcement: Announcement;
};

export default function AnnouncementsEdit({ announcement }: Props) {
    setLayoutProps({
        breadcrumbs: [
            { title: 'Announcements', href: AnnouncementController.index() },
            {
                title: announcement.title,
                href: AnnouncementController.edit(announcement.id),
            },
        ],
    });

    return (
        <div className="max-w-xl space-y-6 p-4">
            <Head title={`Edit ${announcement.title}`} />

            <Heading
                title="Edit announcement"
                description={announcement.title}
            />

            <Form
                {...AnnouncementController.update.form(announcement.id)}
                options={{ preserveScroll: true }}
                className="space-y-6"
            >
                {({ processing, errors }) => (
                    <>
                        <div className="grid gap-2">
                            <Label htmlFor="title">Title</Label>
                            <Input
                                id="title"
                                name="title"
                                defaultValue={announcement.title}
                                required
                            />
                            <InputError message={errors.title} />
                        </div>

                        <div className="grid gap-2">
                            <Label htmlFor="body">Body</Label>
                            <textarea
                                id="body"
                                name="body"
                                rows={6}
                                required
                                defaultValue={announcement.body}
                                className="w-full rounded-md border border-input bg-transparent px-3 py-2 text-sm shadow-xs"
                            />
                            <InputError message={errors.body} />
                        </div>

                        <div className="grid gap-2">
                            <Label htmlFor="expires_at">
                                Expires at (optional)
                            </Label>
                            <Input
                                id="expires_at"
                                name="expires_at"
                                type="datetime-local"
                                defaultValue={
                                    announcement.expires_at?.slice(0, 16) ?? ''
                                }
                            />
                            <InputError message={errors.expires_at} />
                        </div>

                        <Button type="submit" disabled={processing}>
                            Save changes
                        </Button>
                    </>
                )}
            </Form>
        </div>
    );
}
