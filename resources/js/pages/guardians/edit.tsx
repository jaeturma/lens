import { Form, Head, setLayoutProps } from '@inertiajs/react';
import GuardianController from '@/actions/App/Http/Controllers/Guardians/GuardianController';
import Heading from '@/components/heading';
import InputError from '@/components/input-error';
import { Button } from '@/components/ui/button';
import { Checkbox } from '@/components/ui/checkbox';
import { Input } from '@/components/ui/input';
import { Label } from '@/components/ui/label';
import type { Guardian } from '@/types';

type Props = {
    guardian: Guardian;
};

export default function GuardiansEdit({ guardian }: Props) {
    setLayoutProps({
        breadcrumbs: [
            { title: 'Guardians', href: GuardianController.index() },
            {
                title: guardian.name,
                href: GuardianController.edit(guardian.id),
            },
        ],
    });

    return (
        <div className="max-w-xl space-y-6 p-4">
            <Head title={`Edit ${guardian.name}`} />

            <Heading title="Edit guardian" description={guardian.name} />

            <Form
                {...GuardianController.update.form(guardian.id)}
                options={{ preserveScroll: true }}
                className="space-y-6"
            >
                {({ processing, errors }) => (
                    <>
                        <div className="grid gap-2">
                            <Label htmlFor="name">Name</Label>
                            <Input
                                id="name"
                                name="name"
                                defaultValue={guardian.name}
                                required
                            />
                            <InputError message={errors.name} />
                        </div>

                        <div className="grid gap-2">
                            <Label htmlFor="email">Email</Label>
                            <Input
                                id="email"
                                name="email"
                                type="email"
                                defaultValue={guardian.email}
                                required
                            />
                            <InputError message={errors.email} />
                        </div>

                        <div className="grid gap-2">
                            <Label htmlFor="mobile_number">Mobile number</Label>
                            <Input
                                id="mobile_number"
                                name="mobile_number"
                                defaultValue={guardian.mobile_number}
                                required
                            />
                            <InputError message={errors.mobile_number} />
                        </div>

                        <div className="flex items-center gap-2">
                            <Checkbox
                                id="notify_attendance"
                                name="notify_attendance"
                                defaultChecked={guardian.notify_attendance}
                            />
                            <Label htmlFor="notify_attendance">
                                Notify about attendance
                            </Label>
                        </div>

                        <div className="flex items-center gap-2">
                            <Checkbox
                                id="notify_announcements"
                                name="notify_announcements"
                                defaultChecked={guardian.notify_announcements}
                            />
                            <Label htmlFor="notify_announcements">
                                Notify about announcements
                            </Label>
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
