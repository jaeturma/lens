import { Form, Head, Link, setLayoutProps, usePage } from '@inertiajs/react';
import ActivateRfidDeviceController from '@/actions/App/Http/Controllers/RfidDevices/ActivateRfidDeviceController';
import RevokeRfidDeviceController from '@/actions/App/Http/Controllers/RfidDevices/RevokeRfidDeviceController';
import RfidDeviceController from '@/actions/App/Http/Controllers/RfidDevices/RfidDeviceController';
import Heading from '@/components/heading';
import { Badge } from '@/components/ui/badge';
import { Button } from '@/components/ui/button';
import { useClipboard } from '@/hooks/use-clipboard';
import type { RfidDevice } from '@/types';

type Props = {
    device: RfidDevice;
};

type PageProps = {
    flash: { rfidDeviceSecret?: string };
};

function Field({ label, value }: { label: string; value: string }) {
    return (
        <div>
            <dt className="text-sm text-muted-foreground">{label}</dt>
            <dd className="font-medium">{value}</dd>
        </div>
    );
}

export default function RfidDevicesShow({ device }: Props) {
    setLayoutProps({
        breadcrumbs: [
            { title: 'RFID Devices', href: RfidDeviceController.index() },
            {
                title: device.device_code,
                href: RfidDeviceController.show(device.id),
            },
        ],
    });

    const { flash } = usePage<PageProps>().props;
    const [copiedText, copy] = useClipboard();
    const plainSecret = flash?.rfidDeviceSecret;

    return (
        <div className="max-w-xl space-y-6 p-4">
            <Head title={device.device_code} />

            <div className="flex items-center justify-between">
                <Heading
                    title={device.device_code}
                    description={device.location}
                />
                <Badge
                    variant={
                        device.status === 'active' ? 'default' : 'secondary'
                    }
                >
                    {device.status}
                </Badge>
            </div>

            {plainSecret && (
                <div className="space-y-2 rounded-lg border border-amber-300 bg-amber-50 p-4 dark:border-amber-900 dark:bg-amber-950">
                    <p className="text-sm font-medium text-amber-900 dark:text-amber-100">
                        Device secret — save this now
                    </p>
                    <p className="text-sm text-amber-800 dark:text-amber-200">
                        This is the only time the secret will be shown. It is
                        not stored anywhere it can be retrieved again.
                    </p>
                    <div className="flex items-center gap-2">
                        <code className="flex-1 overflow-x-auto rounded-md bg-white px-3 py-2 text-sm dark:bg-black/30">
                            {plainSecret}
                        </code>
                        <Button
                            type="button"
                            variant="secondary"
                            onClick={() => copy(plainSecret)}
                        >
                            {copiedText === plainSecret ? 'Copied!' : 'Copy'}
                        </Button>
                    </div>
                </div>
            )}

            <dl className="grid grid-cols-2 gap-4 rounded-lg border p-4">
                <Field label="Direction mode" value={device.direction_mode} />
                <Field
                    label="Last activity"
                    value={device.last_activity_at ?? 'Never'}
                />
            </dl>

            <div className="flex items-center gap-2">
                <Button asChild variant="secondary">
                    <Link href={RfidDeviceController.edit(device.id)}>
                        Edit
                    </Link>
                </Button>

                {device.status === 'active' ? (
                    <Form
                        {...RevokeRfidDeviceController.form(device.id)}
                        options={{ preserveScroll: true }}
                    >
                        {({ processing }) => (
                            <Button
                                type="submit"
                                variant="destructive"
                                disabled={processing}
                            >
                                Revoke
                            </Button>
                        )}
                    </Form>
                ) : (
                    <Form
                        {...ActivateRfidDeviceController.form(device.id)}
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
        </div>
    );
}
