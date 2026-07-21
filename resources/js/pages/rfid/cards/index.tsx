import { Form, Link } from '@inertiajs/react';
import DeactivateRfidCardController from '@/actions/App/Http/Controllers/RfidCards/DeactivateRfidCardController';
import ReplaceRfidCardController from '@/actions/App/Http/Controllers/RfidCards/ReplaceRfidCardController';
import RfidCardController from '@/actions/App/Http/Controllers/RfidCards/RfidCardController';
import Heading from '@/components/heading';
import InputError from '@/components/input-error';
import { Badge } from '@/components/ui/badge';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Label } from '@/components/ui/label';
import type { Paginated, RfidCard, RfidCardFilters } from '@/types';

type Props = {
    cards: Paginated<RfidCard>;
    filters: RfidCardFilters;
};

function badgeVariant(status: RfidCard['status']) {
    return status === 'active' ? 'default' : 'secondary';
}

export default function RfidCardsIndex({ cards, filters }: Props) {
    return (
        <div className="space-y-6 p-4">
            <div className="flex items-center justify-between">
                <Heading
                    title="RFID Cards"
                    description="Assign, deactivate, and replace student cards"
                />
                <Button asChild>
                    <Link href={RfidCardController.create()}>Assign card</Link>
                </Button>
            </div>

            <Form
                action={RfidCardController.index.url()}
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
                        placeholder="UID or student name"
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
                        <option value="deactivated">Deactivated</option>
                        <option value="replaced">Replaced</option>
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
                            <th className="p-3 font-medium">UID</th>
                            <th className="p-3 font-medium">Student</th>
                            <th className="p-3 font-medium">Status</th>
                            <th className="p-3 font-medium">Assigned</th>
                            <th className="p-3 font-medium">Actions</th>
                        </tr>
                    </thead>
                    <tbody>
                        {cards.data.map((card) => (
                            <tr key={card.id} className="border-t">
                                <td className="p-3 font-mono">{card.uid}</td>
                                <td className="p-3">
                                    {card.student.name} ({card.student.lrn})
                                </td>
                                <td className="p-3">
                                    <Badge variant={badgeVariant(card.status)}>
                                        {card.status}
                                    </Badge>
                                </td>
                                <td className="p-3">{card.created_at}</td>
                                <td className="p-3">
                                    {card.status === 'active' && (
                                        <div className="flex flex-wrap items-center gap-3">
                                            <Form
                                                {...DeactivateRfidCardController.form(
                                                    card.id,
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
                                                        Deactivate
                                                    </button>
                                                )}
                                            </Form>

                                            <Form
                                                {...ReplaceRfidCardController.form(
                                                    card.id,
                                                )}
                                                options={{
                                                    preserveScroll: true,
                                                }}
                                                resetOnSuccess
                                                className="flex items-center gap-2"
                                            >
                                                {({ processing, errors }) => (
                                                    <>
                                                        <Input
                                                            name="uid"
                                                            placeholder="New UID"
                                                            className="h-8 w-32"
                                                            required
                                                        />
                                                        <Button
                                                            type="submit"
                                                            size="sm"
                                                            variant="secondary"
                                                            disabled={
                                                                processing
                                                            }
                                                        >
                                                            Replace
                                                        </Button>
                                                        <InputError
                                                            message={errors.uid}
                                                        />
                                                    </>
                                                )}
                                            </Form>
                                        </div>
                                    )}
                                </td>
                            </tr>
                        ))}
                        {cards.data.length === 0 && (
                            <tr>
                                <td
                                    colSpan={5}
                                    className="p-6 text-center text-muted-foreground"
                                >
                                    No cards found.
                                </td>
                            </tr>
                        )}
                    </tbody>
                </table>
            </div>

            {cards.last_page > 1 && (
                <div className="flex flex-wrap items-center gap-1">
                    {cards.links.map((link, index) => (
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

RfidCardsIndex.layout = {
    breadcrumbs: [
        {
            title: 'RFID Cards',
            href: RfidCardController.index(),
        },
    ],
};
