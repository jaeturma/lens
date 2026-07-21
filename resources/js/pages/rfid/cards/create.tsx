import { Form, Head } from '@inertiajs/react';
import RfidCardController from '@/actions/App/Http/Controllers/RfidCards/RfidCardController';
import Heading from '@/components/heading';
import InputError from '@/components/input-error';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Label } from '@/components/ui/label';
import type { AssignableStudent } from '@/types';

type Props = {
    assignableStudents: AssignableStudent[];
};

export default function RfidCardsCreate({ assignableStudents }: Props) {
    return (
        <div className="max-w-xl space-y-6 p-4">
            <Head title="Assign card" />

            <Heading
                title="Assign card"
                description="Link an RFID card to a student"
            />

            <Form
                {...RfidCardController.store.form()}
                options={{ preserveScroll: true }}
                className="space-y-6"
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
                                {assignableStudents.map((student) => (
                                    <option key={student.id} value={student.id}>
                                        {student.name} ({student.lrn})
                                    </option>
                                ))}
                            </select>
                            <InputError message={errors.student_id} />
                        </div>

                        <div className="grid gap-2">
                            <Label htmlFor="uid">Card UID</Label>
                            <Input id="uid" name="uid" required />
                            <InputError message={errors.uid} />
                        </div>

                        <Button type="submit" disabled={processing}>
                            Assign card
                        </Button>
                    </>
                )}
            </Form>
        </div>
    );
}

RfidCardsCreate.layout = {
    breadcrumbs: [
        { title: 'RFID Cards', href: RfidCardController.index() },
        { title: 'Assign card', href: RfidCardController.create() },
    ],
};
