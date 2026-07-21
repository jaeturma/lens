import { Form, Head, setLayoutProps } from '@inertiajs/react';
import RfidDeviceController from '@/actions/App/Http/Controllers/RfidDevices/RfidDeviceController';
import Heading from '@/components/heading';
import InputError from '@/components/input-error';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Label } from '@/components/ui/label';
import type { RfidDevice } from '@/types';

type Props = {
    device: RfidDevice;
};

export default function RfidDevicesEdit({ device }: Props) {
    setLayoutProps({
        breadcrumbs: [
            { title: 'RFID Devices', href: RfidDeviceController.index() },
            {
                title: device.device_code,
                href: RfidDeviceController.edit(device.id),
            },
        ],
    });

    return (
        <div className="max-w-xl space-y-6 p-4">
            <Head title={`Edit ${device.device_code}`} />

            <Heading title="Edit device" description={device.device_code} />

            <Form
                {...RfidDeviceController.update.form(device.id)}
                options={{ preserveScroll: true }}
                className="space-y-6"
            >
                {({ processing, errors }) => (
                    <>
                        <div className="grid gap-2">
                            <Label htmlFor="location">Location</Label>
                            <Input
                                id="location"
                                name="location"
                                defaultValue={device.location}
                                required
                            />
                            <InputError message={errors.location} />
                        </div>

                        <div className="grid gap-2">
                            <Label htmlFor="direction_mode">
                                Direction mode
                            </Label>
                            <select
                                id="direction_mode"
                                name="direction_mode"
                                required
                                defaultValue={device.direction_mode}
                                className="h-9 w-full rounded-md border border-input bg-transparent px-3 py-1 text-sm shadow-xs"
                            >
                                <option value="entry">Entry</option>
                                <option value="exit">Exit</option>
                                <option value="both">Both</option>
                            </select>
                            <InputError message={errors.direction_mode} />
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
