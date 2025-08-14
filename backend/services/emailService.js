const nodemailer = require('nodemailer');

class EmailService {
    constructor() {
        this.transporter = nodemailer.createTransport({
            service: 'gmail',
            auth: {
                user: process.env.EMAIL_USER,
                pass: process.env.EMAIL_PASS
            }
        });
    }

    // Generar código de 6 dígitos
    generateResetCode() {
        return Math.floor(100000 + Math.random() * 900000).toString();
    }

    // Enviar código de recuperación
    async sendPasswordResetCode(email, code, userName) {
        const mailOptions = {
            from: process.env.EMAIL_USER,
            to: email,
            subject: 'Código de Recuperación de Contraseña - PetMatch',
            html: `
                <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto; padding: 20px;">
                    <div style="background: linear-gradient(135deg, #8B5CF6, #A855F7); padding: 30px; border-radius: 10px; text-align: center; margin-bottom: 20px;">
                        <h1 style="color: white; margin: 0; font-size: 28px;">🐾 PetMatch</h1>
                        <p style="color: white; margin: 10px 0 0 0; font-size: 16px;">Recuperación de Contraseña</p>
                    </div>
                    
                    <div style="background: #f8f9fa; padding: 25px; border-radius: 10px; margin-bottom: 20px;">
                        <h2 style="color: #333; margin-top: 0;">¡Hola ${userName}!</h2>
                        <p style="color: #666; font-size: 16px; line-height: 1.5;">
                            Recibimos una solicitud para restablecer la contraseña de tu cuenta. 
                            Usa el siguiente código para continuar:
                        </p>
                        
                        <div style="background: white; border: 2px solid #8B5CF6; padding: 20px; border-radius: 10px; text-align: center; margin: 20px 0;">
                            <h3 style="margin: 0; color: #8B5CF6; font-size: 32px; letter-spacing: 5px; font-weight: bold;">
                                ${code}
                            </h3>
                        </div>
                        
                        <p style="color: #666; font-size: 14px; margin-bottom: 0;">
                            <strong>⏰ Este código expira en 10 minutos.</strong><br>
                            Si no solicitaste este cambio, puedes ignorar este email.
                        </p>
                    </div>
                    
                    <div style="text-align: center; color: #999; font-size: 12px;">
                        <p>Este es un email automático, por favor no respondas.</p>
                        <p>© 2025 PetMatch - Conectando mascotas con familias</p>
                    </div>
                </div>
            `
        };

        try {
            const result = await this.transporter.sendMail(mailOptions);
            console.log('📧 Email de recuperación enviado exitosamente a:', email);
            return { success: true, messageId: result.messageId };
        } catch (error) {
            console.error('❌ Error enviando email:', error);
            return { success: false, error: error.message };
        }
    }

    // Enviar confirmación de cambio de contraseña
    async sendPasswordChangeConfirmation(email, userName) {
        const mailOptions = {
            from: process.env.EMAIL_USER,
            to: email,
            subject: 'Contraseña Actualizada - PetMatch',
            html: `
                <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto; padding: 20px;">
                    <div style="background: linear-gradient(135deg, #10B981, #059669); padding: 30px; border-radius: 10px; text-align: center; margin-bottom: 20px;">
                        <h1 style="color: white; margin: 0; font-size: 28px;">🐾 PetMatch</h1>
                        <p style="color: white; margin: 10px 0 0 0; font-size: 16px;">Contraseña Actualizada</p>
                    </div>
                    
                    <div style="background: #f8f9fa; padding: 25px; border-radius: 10px; margin-bottom: 20px;">
                        <h2 style="color: #333; margin-top: 0;">¡Hola ${userName}!</h2>
                        <p style="color: #666; font-size: 16px; line-height: 1.5;">
                            Tu contraseña ha sido actualizada exitosamente. Ya puedes iniciar sesión con tu nueva contraseña.
                        </p>
                        
                        <div style="background: #D1FAE5; border: 2px solid #10B981; padding: 20px; border-radius: 10px; text-align: center; margin: 20px 0;">
                            <p style="margin: 0; color: #059669; font-size: 18px; font-weight: bold;">
                                ✅ Contraseña actualizada correctamente
                            </p>
                        </div>
                        
                        <p style="color: #666; font-size: 14px; margin-bottom: 0;">
                            Si no fuiste tú quien cambió la contraseña, contacta inmediatamente con nuestro soporte.
                        </p>
                    </div>
                    
                    <div style="text-align: center; color: #999; font-size: 12px;">
                        <p>Este es un email automático, por favor no respondas.</p>
                        <p>© 2025 PetMatch - Conectando mascotas con familias</p>
                    </div>
                </div>
            `
        };

        try {
            const result = await this.transporter.sendMail(mailOptions);
            console.log('📧 Email de confirmación enviado exitosamente a:', email);
            return { success: true, messageId: result.messageId };
        } catch (error) {
            console.error('❌ Error enviando email de confirmación:', error);
            return { success: false, error: error.message };
        }
    }
}

module.exports = new EmailService();
