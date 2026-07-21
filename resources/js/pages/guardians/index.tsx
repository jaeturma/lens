import { Form, Link } from '@inertiajs/react';
import GuardianController from '@/actions/App/Http/Controllers/Guardians/GuardianController';
import Heading from '@/components/heading';
import { Badge } from '@/components/ui/badge';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Label } from '@/components/ui/label';
import type { Guardian, GuardianFilters, Paginated } from '@/types';

type Props = {
    guardians: Paginated<Guardian>;
    filters: GuardianFilters;
};

export default function GuardiansIndex({ guardians, filters }: Props) {
    return (
        <div className="space-y-6 p-4">
            <div className="flex items-center justify-between">
                <Heading
                    title="Guardians"
                    description="Manage guardian accounts and their linked students"
                />
                <Button asChild>
                    <Link href={GuardianController.create()}>Add guardian</Link>
                </Button>
            </div>

            <Form
                action={GuardianController.index.url()}
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
                        placeholder="Name, email, or mobile number"
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
                        <option value="active">Active</option>
                        <option value="inactive">Inactive</option>
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
                            <th className="p-3 font-medium">Name</th>
                            <th className="p-3 font-medium">Email</th>
                            <th className="p-3 font-medium">Mobile</th>
                            <th className="p-3 font-medium">Status</th>
                            <th className="p-3 font-medium">Actions</th>
                        </tr>
                    </thead>
                    <tbody>
                        {guardians.data.map((guardian) => (
                            <tr key={guardian.id} className="border-t">
                                <td className="p-3">
                                    <Link
                                        href={GuardianController.show(
                                            guardian.id,
                                        )}
                                        className="font-medium hover:underline"
                                    >
                                        {guardian.name}
                                    </Link>
                                </td>
                                <td className="p-3">{guardian.email}</td>
                                <td className="p-3">
                                    {guardian.mobile_number}
                                </td>
                                <td className="p-3">
                                    <Badge
                                        variant={
                                            guardian.status === 'active'
                                                ? 'default'
                                                : 'secondary'
                                        }
                                    >
                                        {guardian.status}
                                    </Badge>
                                </td>
                                <td className="p-3">
                                    <Link
                                        href={GuardianController.edit(
                                            guardian.id,
                                        )}
                                        className="text-sm hover:underline"
                                    >
                                        Edit
                                    </Link>
                                </td>
                            </tr>
                        ))}
                        {guardians.data.length === 0 && (
                            <tr>
                                <td
                                    colSpan={5}
                                    className="p-6 text-center text-muted-foreground"
                                >
                                    No guardians found.
                                </td>
                            </tr>
                        )}
                    </tbody>
                </table>
            </div>

            {guardians.last_page > 1 && (
                <div className="flex flex-wrap items-center gap-1">
                    {guardians.links.map((link, index) => (
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

GuardiansIndex.layout = {
    breadcrumbs: [
        {
            title: 'Guardians',
            href: GuardianController.index(),
        },
    ],
};
