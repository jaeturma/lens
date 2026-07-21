import { Form, Head } from '@inertiajs/react';
import GuardianController from '@/actions/App/Http/Controllers/Guardians/GuardianController';
import Heading from '@/components/heading';
import InputError from '@/components/input-error';
import PasswordInput from '@/components/password-input';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Label } from '@/components/ui/label';

type Props = {
    passwordRules: string;
};

export default function GuardiansCreate({ passwordRules }: Props) {
    return (
        <div className="max-w-xl space-y-6 p-4">
            <Head title="Add guardian" />

            <Heading
                title="Add guardian"
                description="Create a login and profile for a parent/guardian"
            />

            <Form
                {...GuardianController.store.form()}
                options={{ preserveScroll: true }}
                resetOnSuccess={['password', 'password_confirmation']}
                className="space-y-6"
            >
                {({ processing, errors }) => (
                    <>
                        <div className="grid gap-2">
                            <Label htmlFor="name">Name</Label>
                            <Input id="name" name="name" required />
                            <InputError message={errors.name} />
                        </div>

                        <div className="grid gap-2">
                            <Label htmlFor="email">Email</Label>
                            <Input
                                id="email"
                                name="email"
                                type="email"
                                autoComplete="off"
                                required
                            />
                            <InputError message={errors.email} />
                        </div>

                        <div className="grid gap-2">
                            <Label htmlFor="mobile_number">Mobile number</Label>
                            <Input
                                id="mobile_number"
                                name="mobile_number"
                                required
                            />
                            <InputError message={errors.mobile_number} />
                        </div>

                        <div className="grid gap-2">
                            <Label htmlFor="password">Password</Label>
                            <PasswordInput
                                id="password"
                                name="password"
                                autoComplete="new-password"
                                passwordrules={passwordRules}
                                required
                            />
                            <InputError message={errors.password} />
                        </div>

                        <div className="grid gap-2">
                            <Label htmlFor="password_confirmation">
                                Confirm password
                            </Label>
                            <PasswordInput
                                id="password_confirmation"
                                name="password_confirmation"
                                autoComplete="new-password"
                                passwordrules={passwordRules}
                                required
                            />
                            <InputError
                                message={errors.password_confirmation}
                            />
                        </div>

                        <Button type="submit" disabled={processing}>
                            Add guardian
                        </Button>
                    </>
                )}
            </Form>
        </div>
    );
}

GuardiansCreate.layout = {
    breadcrumbs: [
        { title: 'Guardians', href: GuardianController.index() },
        { title: 'Add guardian', href: GuardianController.create() },
    ],
};
