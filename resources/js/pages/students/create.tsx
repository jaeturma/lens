import { Form, Head } from '@inertiajs/react';
import StudentController from '@/actions/App/Http/Controllers/Students/StudentController';
import Heading from '@/components/heading';
import InputError from '@/components/input-error';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Label } from '@/components/ui/label';

export default function StudentsCreate() {
    return (
        <div className="max-w-xl space-y-6 p-4">
            <Head title="Add student" />

            <Heading title="Add student" description="Enroll a new student" />

            <Form
                {...StudentController.store.form()}
                options={{ preserveScroll: true }}
                className="space-y-6"
            >
                {({ processing, errors }) => (
                    <>
                        <div className="grid gap-2">
                            <Label htmlFor="name">Name</Label>
                            <Input id="name" name="name" required />
                            <InputError message={errors.name} />
                        </div>

                        <div className="grid grid-cols-2 gap-4">
                            <div className="grid gap-2">
                                <Label htmlFor="lrn">LRN</Label>
                                <Input
                                    id="lrn"
                                    name="lrn"
                                    maxLength={12}
                                    required
                                />
                                <InputError message={errors.lrn} />
                            </div>

                            <div className="grid gap-2">
                                <Label htmlFor="student_number">
                                    Student number
                                </Label>
                                <Input
                                    id="student_number"
                                    name="student_number"
                                    required
                                />
                                <InputError message={errors.student_number} />
                            </div>
                        </div>

                        <div className="grid gap-2">
                            <Label htmlFor="sex">Sex</Label>
                            <select
                                id="sex"
                                name="sex"
                                required
                                defaultValue=""
                                className="h-9 w-full rounded-md border border-input bg-transparent px-3 py-1 text-sm shadow-xs"
                            >
                                <option value="" disabled>
                                    Select...
                                </option>
                                <option value="male">Male</option>
                                <option value="female">Female</option>
                            </select>
                            <InputError message={errors.sex} />
                        </div>

                        <div className="grid grid-cols-3 gap-4">
                            <div className="grid gap-2">
                                <Label htmlFor="grade">Grade</Label>
                                <Input id="grade" name="grade" required />
                                <InputError message={errors.grade} />
                            </div>

                            <div className="grid gap-2">
                                <Label htmlFor="section">Section</Label>
                                <Input id="section" name="section" required />
                                <InputError message={errors.section} />
                            </div>

                            <div className="grid gap-2">
                                <Label htmlFor="school_year">School year</Label>
                                <Input
                                    id="school_year"
                                    name="school_year"
                                    placeholder="2026-2027"
                                    required
                                />
                                <InputError message={errors.school_year} />
                            </div>
                        </div>

                        <div className="grid gap-2">
                            <Label htmlFor="photo_url">
                                Photo URL (optional)
                            </Label>
                            <Input
                                id="photo_url"
                                name="photo_url"
                                type="url"
                                placeholder="https://..."
                            />
                            <InputError message={errors.photo_url} />
                        </div>

                        <Button type="submit" disabled={processing}>
                            Add student
                        </Button>
                    </>
                )}
            </Form>
        </div>
    );
}

StudentsCreate.layout = {
    breadcrumbs: [
        { title: 'Students', href: StudentController.index() },
        { title: 'Add student', href: StudentController.create() },
    ],
};
