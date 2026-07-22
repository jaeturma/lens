import { Form, Head } from '@inertiajs/react';
import AnnouncementController from '@/actions/App/Http/Controllers/Announcements/AnnouncementController';
import Heading from '@/components/heading';
import InputError from '@/components/input-error';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Label } from '@/components/ui/label';
import type { AssignableStudent } from '@/types';

type Props = {
    assignableStudents: AssignableStudent[];
};

export default function AnnouncementsCreate({ assignableStudents }: Props) {
    return (
        <div className="max-w-xl space-y-6 p-4">
            <Head title="New announcement" />

            <Heading
                title="New announcement"
                description="Created as a draft — publish it when ready"
            />

            <Form
                {...AnnouncementController.store.form()}
                options={{ preserveScroll: true }}
                className="space-y-6"
            >
                {({ processing, errors }) => (
                    <>
                        <div className="grid gap-2">
                            <Label htmlFor="title">Title</Label>
                            <Input
                                id="title"
                                name="title"
                                placeholder="Foundation Day"
                                required
                            />
                            <InputError message={errors.title} />
                        </div>

                        <div className="grid gap-2">
                            <Label htmlFor="body">Body</Label>
                            <textarea
                                id="body"
                                name="body"
                                rows={6}
                                required
                                className="w-full rounded-md border border-input bg-transparent px-3 py-2 text-sm shadow-xs"
                            />
                            <InputError message={errors.body} />
                        </div>

                        <div className="grid gap-2">
                            <Label htmlFor="expires_at">
                                Expires at (optional)
                            </Label>
                            <Input
                                id="expires_at"
                                name="expires_at"
                                type="datetime-local"
                            />
                            <InputError message={errors.expires_at} />
                        </div>

                        <div className="grid gap-2">
                            <Label htmlFor="audience_type">Audience</Label>
                            <select
                                id="audience_type"
                                name="audience_type"
                                required
                                defaultValue="all"
                                className="h-9 w-full rounded-md border border-input bg-transparent px-3 py-1 text-sm shadow-xs"
                            >
                                <option value="all">All guardians</option>
                                <option value="grade">A grade</option>
                                <option value="section">A section</option>
                                <option value="students">
                                    Selected students
                                </option>
                            </select>
                            <InputError message={errors.audience_type} />
                        </div>

                        <div className="grid gap-2">
                            <Label htmlFor="audience_grade">
                                Grade (for Grade or Section audiences)
                            </Label>
                            <Input
                                id="audience_grade"
                                name="audience_grade"
                                placeholder="Grade 7"
                            />
                            <InputError message={errors.audience_grade} />
                        </div>

                        <div className="grid gap-2">
                            <Label htmlFor="audience_section">
                                Section (for Section audiences)
                            </Label>
                            <Input
                                id="audience_section"
                                name="audience_section"
                                placeholder="Diamond"
                            />
                            <InputError message={errors.audience_section} />
                        </div>

                        <div className="grid gap-2">
                            <Label htmlFor="student_ids">
                                Students (for Selected students audiences —
                                ctrl/cmd-click to select more than one)
                            </Label>
                            <select
                                id="student_ids"
                                name="student_ids[]"
                                multiple
                                size={6}
                                className="w-full rounded-md border border-input bg-transparent px-3 py-1 text-sm shadow-xs"
                            >
                                {assignableStudents.map((student) => (
                                    <option key={student.id} value={student.id}>
                                        {student.name} ({student.lrn})
                                    </option>
                                ))}
                            </select>
                            <InputError message={errors.student_ids} />
                        </div>

                        <Button type="submit" disabled={processing}>
                            Create draft
                        </Button>
                    </>
                )}
            </Form>
        </div>
    );
}

AnnouncementsCreate.layout = {
    breadcrumbs: [
        { title: 'Announcements', href: AnnouncementController.index() },
        { title: 'New announcement', href: AnnouncementController.create() },
    ],
};
