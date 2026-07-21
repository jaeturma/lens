import { Form, Link } from '@inertiajs/react';
import ActivateRfidDeviceController from '@/actions/App/Http/Controllers/RfidDevices/ActivateRfidDeviceController';
import RevokeRfidDeviceController from '@/actions/App/Http/Controllers/RfidDevices/RevokeRfidDeviceController';
import RfidDeviceController from '@/actions/App/Http/Controllers/RfidDevices/RfidDeviceController';
import Heading from '@/components/heading';
import { Badge } from '@/components/ui/badge';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Label } from '@/components/ui/label';
import type { Paginated, RfidDevice, RfidDeviceFilters } from '@/types';

type Props = {
    devices: Paginated<RfidDevice>;
    filters: RfidDeviceFilters;
};

export default function RfidDevicesIndex({ devices, filters }: Props) {
    return (
        <div className="space-y-6 p-4">
            <div className="flex items-center justify-between">
                <Heading
                    title="RFID Devices"
                    description="Manage registered scan readers"
                />
                <Button asChild>
                    <Link href={RfidDeviceController.create()}>
                        Register device
                    </Link>
                </Button>
            </div>

            <Form
                action={RfidDeviceController.index.url()}
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
                        placeholder="Device code or location"
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
                        <option value="revoked">Revoked</option>
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
                            <th className="p-3 font-medium">Device code</th>
                            <th className="p-3 font-medium">Location</th>
                            <th className="p-3 font-medium">Direction</th>
                            <th className="p-3 font-medium">Last activity</th>
                            <th className="p-3 font-medium">Status</th>
                            <th className="p-3 font-medium">Actions</th>
                        </tr>
                    </thead>
                    <tbody>
                        {devices.data.map((device) => (
                            <tr key={device.id} className="border-t">
                                <td className="p-3">
                                    <Link
                                        href={RfidDeviceController.show(
                                            device.id,
                                        )}
                                        className="font-medium hover:underline"
                                    >
                                        {device.device_code}
                                    </Link>
                                </td>
                                <td className="p-3">{device.location}</td>
                                <td className="p-3">{device.direction_mode}</td>
                                <td className="p-3">
                                    {device.last_activity_at ?? 'Never'}
                                </td>
                                <td className="p-3">
                                    <Badge
                                        variant={
                                            device.status === 'active'
                                                ? 'default'
                                                : 'secondary'
                                        }
                                    >
                                        {device.status}
                                    </Badge>
                                </td>
                                <td className="p-3">
                                    <div className="flex items-center gap-2">
                                        <Link
                                            href={RfidDeviceController.edit(
                                                device.id,
                                            )}
                                            className="text-sm hover:underline"
                                        >
                                            Edit
                                        </Link>
                                        {device.status === 'active' ? (
                                            <Form
                                                {...RevokeRfidDeviceController.form(
                                                    device.id,
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
                                        ) : (
                                            <Form
                                                {...ActivateRfidDeviceController.form(
                                                    device.id,
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
                                                        Activate
                                                    </button>
                                                )}
                                            </Form>
                                        )}
                                    </div>
                                </td>
                            </tr>
                        ))}
                        {devices.data.length === 0 && (
                            <tr>
                                <td
                                    colSpan={6}
                                    className="p-6 text-center text-muted-foreground"
                                >
                                    No devices found.
                                </td>
                            </tr>
                        )}
                    </tbody>
                </table>
            </div>

            {devices.last_page > 1 && (
                <div className="flex flex-wrap items-center gap-1">
                    {devices.links.map((link, index) => (
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

RfidDevicesIndex.layout = {
    breadcrumbs: [
        {
            title: 'RFID Devices',
            href: RfidDeviceController.index(),
        },
    ],
};
