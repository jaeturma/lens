import { Form, Head } from '@inertiajs/react';
import RfidDeviceController from '@/actions/App/Http/Controllers/RfidDevices/RfidDeviceController';
import Heading from '@/components/heading';
import InputError from '@/components/input-error';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Label } from '@/components/ui/label';

export default function RfidDevicesCreate() {
    return (
        <div className="max-w-xl space-y-6 p-4">
            <Head title="Register device" />

            <Heading
                title="Register device"
                description="Add a new RFID scan reader"
            />

            <Form
                {...RfidDeviceController.store.form()}
                options={{ preserveScroll: true }}
                className="space-y-6"
            >
                {({ processing, errors }) => (
                    <>
                        <div className="grid gap-2">
                            <Label htmlFor="device_code">Device code</Label>
                            <Input
                                id="device_code"
                                name="device_code"
                                placeholder="GATE-001"
                                required
                            />
                            <InputError message={errors.device_code} />
                        </div>

                        <div className="grid gap-2">
                            <Label htmlFor="location">Location</Label>
                            <Input
                                id="location"
                                name="location"
                                placeholder="Main Gate"
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
                                defaultValue=""
                                className="h-9 w-full rounded-md border border-input bg-transparent px-3 py-1 text-sm shadow-xs"
                            >
                                <option value="" disabled>
                                    Select...
                                </option>
                                <option value="entry">Entry</option>
                                <option value="exit">Exit</option>
                                <option value="both">Both</option>
                            </select>
                            <InputError message={errors.direction_mode} />
                        </div>

                        <Button type="submit" disabled={processing}>
                            Register device
                        </Button>
                    </>
                )}
            </Form>
        </div>
    );
}

RfidDevicesCreate.layout = {
    breadcrumbs: [
        { title: 'RFID Devices', href: RfidDeviceController.index() },
        { title: 'Register device', href: RfidDeviceController.create() },
    ],
};
