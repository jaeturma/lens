import { Form, Head, setLayoutProps } from '@inertiajs/react';
import StudentController from '@/actions/App/Http/Controllers/Students/StudentController';
import Heading from '@/components/heading';
import InputError from '@/components/input-error';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Label } from '@/components/ui/label';
import type { Student } from '@/types';

type Props = {
    student: Student;
};

export default function StudentsEdit({ student }: Props) {
    setLayoutProps({
        breadcrumbs: [
            { title: 'Students', href: StudentController.index() },
            { title: student.name, href: StudentController.edit(student.id) },
        ],
    });

    return (
        <div className="max-w-xl space-y-6 p-4">
            <Head title={`Edit ${student.name}`} />

            <Heading title="Edit student" description={student.name} />

            <Form
                {...StudentController.update.form(student.id)}
                options={{ preserveScroll: true }}
                className="space-y-6"
            >
                {({ processing, errors }) => (
                    <>
                        <div className="grid gap-2">
                            <Label htmlFor="name">Name</Label>
                            <Input
                                id="name"
                                name="name"
                                defaultValue={student.name}
                                required
                            />
                            <InputError message={errors.name} />
                        </div>

                        <div className="grid grid-cols-2 gap-4">
                            <div className="grid gap-2">
                                <Label htmlFor="lrn">LRN</Label>
                                <Input
                                    id="lrn"
                                    name="lrn"
                                    maxLength={12}
                                    defaultValue={student.lrn}
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
                                    defaultValue={student.student_number}
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
                                defaultValue={student.sex}
                                className="h-9 w-full rounded-md border border-input bg-transparent px-3 py-1 text-sm shadow-xs"
                            >
                                <option value="male">Male</option>
                                <option value="female">Female</option>
                            </select>
                            <InputError message={errors.sex} />
                        </div>

                        <div className="grid grid-cols-3 gap-4">
                            <div className="grid gap-2">
                                <Label htmlFor="grade">Grade</Label>
                                <Input
                                    id="grade"
                                    name="grade"
                                    defaultValue={student.grade}
                                    required
                                />
                                <InputError message={errors.grade} />
                            </div>

                            <div className="grid gap-2">
                                <Label htmlFor="section">Section</Label>
                                <Input
                                    id="section"
                                    name="section"
                                    defaultValue={student.section}
                                    required
                                />
                                <InputError message={errors.section} />
                            </div>

                            <div className="grid gap-2">
                                <Label htmlFor="school_year">School year</Label>
                                <Input
                                    id="school_year"
                                    name="school_year"
                                    defaultValue={student.school_year}
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
                                defaultValue={student.photo_url ?? ''}
                                placeholder="https://..."
                            />
                            <InputError message={errors.photo_url} />
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
