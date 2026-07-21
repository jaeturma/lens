import { Form, Head, Link, setLayoutProps } from '@inertiajs/react';
import ActivateGuardianController from '@/actions/App/Http/Controllers/Guardians/ActivateGuardianController';
import DeactivateGuardianController from '@/actions/App/Http/Controllers/Guardians/DeactivateGuardianController';
import GuardianController from '@/actions/App/Http/Controllers/Guardians/GuardianController';
import RevokeGuardianStudentLinkController from '@/actions/App/Http/Controllers/Guardians/RevokeGuardianStudentLinkController';
import StoreGuardianStudentLinkController from '@/actions/App/Http/Controllers/Guardians/StoreGuardianStudentLinkController';
import Heading from '@/components/heading';
import InputError from '@/components/input-error';
import { Badge } from '@/components/ui/badge';
import { Button } from '@/components/ui/button';
import { Checkbox } from '@/components/ui/checkbox';
import { Label } from '@/components/ui/label';
import type { Guardian, GuardianStudentLink, LinkableStudent } from '@/types';

type Props = {
    guardian: Guardian;
    links: GuardianStudentLink[];
    linkableStudents: LinkableStudent[];
};

function Field({ label, value }: { label: string; value: string }) {
    return (
        <div>
            <dt className="text-sm text-muted-foreground">{label}</dt>
            <dd className="font-medium">{value}</dd>
        </div>
    );
}

export default function GuardiansShow({
    guardian,
    links,
    linkableStudents,
}: Props) {
    setLayoutProps({
        breadcrumbs: [
            { title: 'Guardians', href: GuardianController.index() },
            {
                title: guardian.name,
                href: GuardianController.show(guardian.id),
            },
        ],
    });

    const activeLinks = links.filter((link) => link.status === 'active');

    return (
        <div className="max-w-2xl space-y-6 p-4">
            <Head title={guardian.name} />

            <div className="flex items-center justify-between">
                <Heading title={guardian.name} description={guardian.email} />
                <Badge
                    variant={
                        guardian.status === 'active' ? 'default' : 'secondary'
                    }
                >
                    {guardian.status}
                </Badge>
            </div>

            <dl className="grid grid-cols-2 gap-4 rounded-lg border p-4">
                <Field label="Email" value={guardian.email} />
                <Field label="Mobile number" value={guardian.mobile_number} />
            </dl>

            <div className="flex items-center gap-2">
                <Button asChild variant="secondary">
                    <Link href={GuardianController.edit(guardian.id)}>
                        Edit
                    </Link>
                </Button>

                {guardian.status === 'active' ? (
                    <Form
                        {...DeactivateGuardianController.form(guardian.id)}
                        options={{ preserveScroll: true }}
                    >
                        {({ processing }) => (
                            <Button
                                type="submit"
                                variant="destructive"
                                disabled={processing}
                            >
                                Deactivate
                            </Button>
                        )}
                    </Form>
                ) : (
                    <Form
                        {...ActivateGuardianController.form(guardian.id)}
                        options={{ preserveScroll: true }}
                    >
                        {({ processing }) => (
                            <Button type="submit" disabled={processing}>
                                Activate
                            </Button>
                        )}
                    </Form>
                )}
            </div>

            <div className="space-y-4">
                <Heading variant="small" title="Linked students" />

                <div className="overflow-hidden rounded-lg border">
                    <table className="w-full text-sm">
                        <thead className="bg-muted/50 text-left">
                            <tr>
                                <th className="p-3 font-medium">Student</th>
                                <th className="p-3 font-medium">
                                    Relationship
                                </th>
                                <th className="p-3 font-medium">Primary</th>
                                <th className="p-3 font-medium">Status</th>
                                <th className="p-3 font-medium">Actions</th>
                            </tr>
                        </thead>
                        <tbody>
                            {links.map((link) => (
                                <tr key={link.id} className="border-t">
                                    <td className="p-3">
                                        {link.student.name} ({link.student.lrn})
                                    </td>
                                    <td className="p-3">
                                        {link.relationship_type}
                                    </td>
                                    <td className="p-3">
                                        {link.is_primary_contact ? 'Yes' : 'No'}
                                    </td>
                                    <td className="p-3">
                                        <Badge
                                            variant={
                                                link.status === 'active'
                                                    ? 'default'
                                                    : 'secondary'
                                            }
                                        >
                                            {link.status}
                                        </Badge>
                                    </td>
                                    <td className="p-3">
                                        {link.status === 'active' && (
                                            <Form
                                                {...RevokeGuardianStudentLinkController.form(
                                                    [guardian.id, link.id],
                                                )}
                                                options={{
                                                    preserveScroll: true,
                                                }}
                                            >
                                                {({ processing }) => (
                                                    <button
                                                        type="submit"
                                                        disabled={processing}
                                                        className="text-sm text-destructive hover:underline"
                                                    >
                                                        Revoke
                                                    </button>
                                                )}
                                            </Form>
                                        )}
                                    </td>
                                </tr>
                            ))}
                            {links.length === 0 && (
                                <tr>
                                    <td
                                        colSpan={5}
                                        className="p-6 text-center text-muted-foreground"
                                    >
                                        No linked students yet.
                                    </td>
                                </tr>
                            )}
                        </tbody>
                    </table>
                </div>

                <div className="rounded-lg border p-4">
                    <Heading
                        variant="small"
                        title="Link a student"
                        description="Connect this guardian to a student"
                    />

                    <Form
                        {...StoreGuardianStudentLinkController.form(
                            guardian.id,
                        )}
                        options={{ preserveScroll: true }}
                        resetOnSuccess
                        className="mt-4 space-y-4"
                    >
                        {({ processing, errors }) => (
                            <>
                                <div className="grid gap-2">
                                    <Label htmlFor="student_id">Student</Label>
                                    <select
                                        id="student_id"
                                        name="student_id"
                                        required
                                        defaultValue=""
                                        className="h-9 w-full rounded-md border border-input bg-transparent px-3 py-1 text-sm shadow-xs"
                                    >
                                        <option value="" disabled>
                                            Select a student...
                                        </option>
                                        {linkableStudents.map((student) => (
                                            <option
                                                key={student.id}
                                                value={student.id}
                                            >
                                                {student.name} ({student.lrn})
                                            </option>
                                        ))}
                                    </select>
                                    <InputError message={errors.student_id} />
                                </div>

                                <div className="grid gap-2">
                                    <Label htmlFor="relationship_type">
                                        Relationship
                                    </Label>
                                    <select
                                        id="relationship_type"
                                        name="relationship_type"
                                        required
                                        defaultValue=""
                                        className="h-9 w-full rounded-md border border-input bg-transparent px-3 py-1 text-sm shadow-xs"
                                    >
                                        <option value="" disabled>
                                            Select...
                                        </option>
                                        <option value="mother">Mother</option>
                                        <option value="father">Father</option>
                                        <option value="guardian">
                                            Guardian
                                        </option>
                                        <option value="other">Other</option>
                                    </select>
                                    <InputError
                                        message={errors.relationship_type}
                                    />
                                </div>

                                <div className="flex items-center gap-2">
                                    <Checkbox
                                        id="is_primary_contact"
                                        name="is_primary_contact"
                                    />
                                    <Label htmlFor="is_primary_contact">
                                        Primary contact
                                    </Label>
                                </div>

                                <div className="flex items-center gap-2">
                                    <Checkbox
                                        id="notifications_enabled"
                                        name="notifications_enabled"
                                        defaultChecked
                                    />
                                    <Label htmlFor="notifications_enabled">
                                        Notifications enabled
                                    </Label>
                                </div>

                                <Button type="submit" disabled={processing}>
                                    Add link
                                </Button>
                            </>
                        )}
                    </Form>
                </div>
            </div>

            {activeLinks.length === 0 && links.length > 0 && (
                <p className="text-sm text-muted-foreground">
                    This guardian has no active linked students.
                </p>
            )}
        </div>
    );
}
