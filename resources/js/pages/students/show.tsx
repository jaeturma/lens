import { Form, Head, Link, setLayoutProps } from '@inertiajs/react';
import ActivateStudentController from '@/actions/App/Http/Controllers/Students/ActivateStudentController';
import DeactivateStudentController from '@/actions/App/Http/Controllers/Students/DeactivateStudentController';
import StudentController from '@/actions/App/Http/Controllers/Students/StudentController';
import Heading from '@/components/heading';
import { Badge } from '@/components/ui/badge';
import { Button } from '@/components/ui/button';
import type { Student } from '@/types';

type Props = {
    student: Student;
};

function Field({ label, value }: { label: string; value: string }) {
    return (
        <div>
            <dt className="text-sm text-muted-foreground">{label}</dt>
            <dd className="font-medium">{value}</dd>
        </div>
    );
}

export default function StudentsShow({ student }: Props) {
    setLayoutProps({
        breadcrumbs: [
            { title: 'Students', href: StudentController.index() },
            { title: student.name, href: StudentController.show(student.id) },
        ],
    });

    return (
        <div className="max-w-xl space-y-6 p-4">
            <Head title={student.name} />

            <div className="flex items-center justify-between">
                <Heading
                    title={student.name}
                    description={`${student.grade} - ${student.section}`}
                />
                <Badge
                    variant={
                        student.status === 'active' ? 'default' : 'secondary'
                    }
                >
                    {student.status}
                </Badge>
            </div>

            <dl className="grid grid-cols-2 gap-4 rounded-lg border p-4">
                <Field label="LRN" value={student.lrn} />
                <Field label="Student number" value={student.student_number} />
                <Field label="Sex" value={student.sex} />
                <Field label="School year" value={student.school_year} />
            </dl>

            <div className="flex items-center gap-2">
                <Button asChild variant="secondary">
                    <Link href={StudentController.edit(student.id)}>Edit</Link>
                </Button>

                {student.status === 'active' ? (
                    <Form
                        {...DeactivateStudentController.form(student.id)}
                        options={{ preserveScroll: true }}
                    >
                        {({ processing }) => (
                            <Button
                                type="submit"
                                variant="destructive"
                                disabled={processing}
                            >
                                Deactivate
                            </Button>
                        )}
                    </Form>
                ) : (
                    <Form
                        {...ActivateStudentController.form(student.id)}
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
