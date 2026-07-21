import { Form, Link } from '@inertiajs/react';
import RfidScanController from '@/actions/App/Http/Controllers/RfidScans/RfidScanController';
import Heading from '@/components/heading';
import { Badge } from '@/components/ui/badge';
import { Button } from '@/components/ui/button';
import { Label } from '@/components/ui/label';
import type { Paginated, RfidDevice, RfidScan, RfidScanFilters } from '@/types';

type Props = {
    scans: Paginated<RfidScan>;
    filters: RfidScanFilters;
    devices: Pick<RfidDevice, 'id' | 'device_code' | 'location'>[];
};

function classificationVariant(classification: RfidScan['classification']) {
    return classification === 'valid' ? 'default' : 'destructive';
}

export default function RfidScansIndex({ scans, filters, devices }: Props) {
    return (
        <div className="space-y-6 p-4">
            <Heading
                title="Recent Scans"
                description="Read-only log of raw RFID scans"
            />

            <Form
                action={RfidScanController.index.url()}
                method="get"
                options={{
                    preserveState: true,
                    preserveScroll: true,
                    replace: true,
                }}
                className="flex flex-wrap items-end gap-4"
            >
                <div className="grid gap-2">
                    <Label htmlFor="rfid_device_id">Device</Label>
                    <select
                        id="rfid_device_id"
                        name="rfid_device_id"
                        defaultValue={filters.rfid_device_id ?? ''}
                        className="h-9 rounded-md border border-input bg-transparent px-3 py-1 text-sm shadow-xs"
                    >
                        <option value="">All</option>
                        {devices.map((device) => (
                            <option key={device.id} value={device.id}>
                                {device.device_code} ({device.location})
                            </option>
                        ))}
                    </select>
                </div>
                <div className="grid gap-2">
                    <Label htmlFor="classification">Classification</Label>
                    <select
                        id="classification"
                        name="classification"
                        defaultValue={filters.classification ?? ''}
                        className="h-9 rounded-md border border-input bg-transparent px-3 py-1 text-sm shadow-xs"
                    >
                        <option value="">All</option>
                        <option value="valid">Valid</option>
                        <option value="duplicate_window">
                            Duplicate window
                        </option>
                        <option value="unknown_card">Unknown card</option>
                        <option value="inactive_card">Inactive card</option>
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
                            <th className="p-3 font-medium">Device</th>
                            <th className="p-3 font-medium">UID</th>
                            <th className="p-3 font-medium">Classification</th>
                            <th className="p-3 font-medium">Device time</th>
                            <th className="p-3 font-medium">Received</th>
                        </tr>
                    </thead>
                    <tbody>
                        {scans.data.map((scan) => (
                            <tr key={scan.id} className="border-t">
                                <td className="p-3">
                                    {scan.device.device_code}
                                </td>
                                <td className="p-3 font-mono">{scan.uid}</td>
                                <td className="p-3">
                                    <Badge
                                        variant={classificationVariant(
                                            scan.classification,
                                        )}
                                    >
                                        {scan.classification}
                                    </Badge>
                                </td>
                                <td className="p-3">{scan.device_timestamp}</td>
                                <td className="p-3">{scan.created_at}</td>
                            </tr>
                        ))}
                        {scans.data.length === 0 && (
                            <tr>
                                <td
                                    colSpan={5}
                                    className="p-6 text-center text-muted-foreground"
                                >
                                    No scans found.
                                </td>
                            </tr>
                        )}
                    </tbody>
                </table>
            </div>

            {scans.last_page > 1 && (
                <div className="flex flex-wrap items-center gap-1">
                    {scans.links.map((link, index) => (
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

RfidScansIndex.layout = {
    breadcrumbs: [
        {
            title: 'RFID Scans',
            href: RfidScanController.index(),
        },
    ],
};
