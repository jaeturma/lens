import { Form, Link } from '@inertiajs/react';
import ActivateStudentController from '@/actions/App/Http/Controllers/Students/ActivateStudentController';
import DeactivateStudentController from '@/actions/App/Http/Controllers/Students/DeactivateStudentController';
import StudentController from '@/actions/App/Http/Controllers/Students/StudentController';
import Heading from '@/components/heading';
import { Badge } from '@/components/ui/badge';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Label } from '@/components/ui/label';
import type { Paginated, Student, StudentFilters } from '@/types';

type Props = {
    students: Paginated<Student>;
    filters: StudentFilters;
};

export default function StudentsIndex({ students, filters }: Props) {
    return (
        <div className="space-y-6 p-4">
            <div className="flex items-center justify-between">
                <Heading
                    title="Students"
                    description="Manage enrolled students"
                />
                <Button asChild>
                    <Link href={StudentController.create()}>Add student</Link>
                </Button>
            </div>

            <Form
                action={StudentController.index.url()}
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
                        placeholder="Name, LRN, or student number"
                        defaultValue={filters.q ?? ''}
                        className="w-64"
                    />
                </div>
                <div className="grid gap-2">
                    <Label htmlFor="grade">Grade</Label>
                    <Input
                        id="grade"
                        name="grade"
                        defaultValue={filters.grade ?? ''}
                        className="w-32"
                    />
                </div>
                <div className="grid gap-2">
                    <Label htmlFor="section">Section</Label>
                    <Input
                        id="section"
                        name="section"
                        defaultValue={filters.section ?? ''}
                        className="w-32"
                    />
                </div>
                <div className="grid gap-2">
                    <Label htmlFor="school_year">School year</Label>
                    <Input
                        id="school_year"
                        name="school_year"
                        defaultValue={filters.school_year ?? ''}
                        className="w-32"
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
                        <option value="inactive">Inactive</option>
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
                            <th className="p-3 font-medium">Name</th>
                            <th className="p-3 font-medium">LRN</th>
                            <th className="p-3 font-medium">Student #</th>
                            <th className="p-3 font-medium">Grade</th>
                            <th className="p-3 font-medium">Section</th>
                            <th className="p-3 font-medium">School year</th>
                            <th className="p-3 font-medium">Status</th>
                            <th className="p-3 font-medium">Actions</th>
                        </tr>
                    </thead>
                    <tbody>
                        {students.data.map((student) => (
                            <tr key={student.id} className="border-t">
                                <td className="p-3">
                                    <Link
                                        href={StudentController.show(
                                            student.id,
                                        )}
                                        className="font-medium hover:underline"
                                    >
                                        {student.name}
                                    </Link>
                                </td>
                                <td className="p-3">{student.lrn}</td>
                                <td className="p-3">
                                    {student.student_number}
                                </td>
                                <td className="p-3">{student.grade}</td>
                                <td className="p-3">{student.section}</td>
                                <td className="p-3">{student.school_year}</td>
                                <td className="p-3">
                                    <Badge
                                        variant={
                                            student.status === 'active'
                                                ? 'default'
                                                : 'secondary'
                                        }
                                    >
                                        {student.status}
                                    </Badge>
                                </td>
                                <td className="p-3">
                                    <div className="flex items-center gap-2">
                                        <Link
                                            href={StudentController.edit(
                                                student.id,
                                            )}
                                            className="text-sm hover:underline"
                                        >
                                            Edit
                                        </Link>
                                        {student.status === 'active' ? (
                                            <Form
                                                {...DeactivateStudentController.form(
                                                    student.id,
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
                                        ) : (
                                            <Form
                                                {...ActivateStudentController.form(
                                                    student.id,
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
                        {students.data.length === 0 && (
                            <tr>
                                <td
                                    colSpan={8}
                                    className="p-6 text-center text-muted-foreground"
                                >
                                    No students found.
                                </td>
                            </tr>
                        )}
                    </tbody>
                </table>
            </div>

            {students.last_page > 1 && (
                <div className="flex flex-wrap items-center gap-1">
                    {students.links.map((link, index) => (
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

StudentsIndex.layout = {
    breadcrumbs: [
        {
            title: 'Students',
            href: StudentController.index(),
        },
    ],
};
