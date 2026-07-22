import { Form, Head } from '@inertiajs/react';
import AnnouncementController from '@/actions/App/Http/Controllers/Announcements/AnnouncementController';
import Heading from '@/components/heading';
import InputError from '@/components/input-error';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Label } from '@/components/ui/label';

export default function AnnouncementsCreate() {
    return (
        <div className="max-w-xl space-y-6 p-4">
            <Head title="New announcement" />

            <Heading
                title="New announcement"
                description="Created as a draft — publish it when ready"
            />

            <Form
                {...AnnouncementController.store.form()}
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
                                placeholder="Foundation Day"
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
                            />
                            <InputError message={errors.expires_at} />
                        </div>

                        <Button type="submit" disabled={processing}>
                            Create draft
                        </Button>
                    </>
                )}
            </Form>
        </div>
    );
}

AnnouncementsCreate.layout = {
    breadcrumbs: [
        { title: 'Announcements', href: AnnouncementController.index() },
        { title: 'New announcement', href: AnnouncementController.create() },
    ],
};
